require 'rack/utils'
require 'cgi'

module Rack
  class Embed
    def initialize(app, opts = {})
      @app = app
      @max_size = opts[:max_size] || 1024
      @mime_types = opts[:mime_types] || %w(text/css application/xhtml+xml text/html)
    end

    def call(env)
      ua = env['HTTP_USER_AGENT']

      # Replace this with something more sophisticated
      # Supported according to http://en.wikipedia.org/wiki/Data_URI_scheme
      if !ua || ua !~ /WebKit|Gecko|Opera|Konqueror|MSIE 8.0/
        return @app.call(env)
      end

      original_env = env.clone
      response = @app.call(env)
      return response if !applies_to?(response)

      status, header, body = response
      body = css?(header) ? css_embed_images(body.first, original_env) : html_embed_images(body.first, original_env)
      header['Content-Length'] = Rack::Utils.bytesize(body).to_s

      [status, header, [body]]
    rescue Exception => ex
      env['rack.errors'].write("#{ex.message}\n") if env['rack.errors']
      [500, {}, ex.message]
    end

    private

    def unescape(url)
      CGI.unescapeHTML(url)
    end

    def escape(url)
      CGI.escapeHTML(url)
    end

    def css_embed_images(body, env)
      body.gsub!(/url\(([^\)]+)\)/) do
        "url(#{escape get_image(env, unescape($1))})"
      end
      body
    end

    def html_embed_images(body, env)
      body.gsub!(/(<img[^>]+src=)("[^"]+"|'[^']+')/) do
        img = $1
        src = unescape($2)
        "#{img}#{src[0..0]}#{escape(get_image(env, src[1..-2]))}#{src[-1..-1]}"
      end
      body
    end

    def get_image(env, src)
      return src if src =~ %r{^\w+://|^data:}
      begin
        if src[0..0] != '/'
          path = env['PATH_INFO']
          i = path.rindex('/')
          src = path[0..i] + src
        end

        uri = env['REQUEST_URI'] || env['PATH_INFO']
        i = uri.index('?')
        uri = src + (i ? uri[i..-1] : '')

        i = src.index('?')
        if i
          path = src[0...i]
          query = env['QUERY_STRING'] || ''
          query += (query.empty? ? '' : '&') + src[i+1..-1]
        else
          path = src
          query = env['QUERY_STRING']
        end

        inclusion_env = env.merge('PATH_INFO' => path,
                                  'REQUEST_PATH' => path,
                                  'REQUEST_URI' => uri,
                                  'REQUEST_METHOD' => 'GET',
                                  'QUERY_STRING' => query)
        inclusion_env.delete('rack.request')
        status, header, body = @app.call(inclusion_env)
        type = content_type(header)

        return src if status != 200 || !type

        return src if body.respond_to?(:to_path) && ::File.size(body.to_path) > @max_size

        return src if body.respond_to?(:path) && ::File.size(body.path) > @max_size

        body = join_body(body)
        return src if Rack::Utils.bytesize(body) > @max_size

        body = [body].pack('m')
        body.gsub!("\n", '')
        "data:#{type};base64,#{body}"
      rescue
        src
      end
    end

    def applies_to?(response)
      status, header, body = response

      # Some stati don't have to be processed
      return false if [301, 302, 303, 307].include?(status)

      # Check mime type
      return false if !@mime_types.include?(content_type(header))

      response[2] = [body = join_body(body)]

      # Something to embed?
      if css? header
        body.include?('url(')
      else
        body =~ /<img[^>]+src=/
      end
    end

    def content_type(header)
      header['Content-Type'] && header['Content-Type'].split(';').first.strip
    end

    def css?(header)
      content_type(header) == 'text/css'
    end

    # Join response body
    def join_body(body)
      parts = ''
      body.each { |part| parts << part }
      parts
    end
  end
end
