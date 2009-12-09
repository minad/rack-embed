require 'test/unit'
require 'rack/urlmap'

path = File.expand_path(File.dirname(__FILE__))
$: << path << File.join(path, 'lib')

require 'rack/embed'

class TestRackEmbed < Test::Unit::TestCase
  def test_response_passthrough
    mock_app = const([200, {}, ['Hei!']])
    esi_app = Rack::Embed.new(mock_app)

    assert_same_response(mock_app, esi_app)
  end

  def test_respect_for_content_type
    mock_app = const([200, {'Content-Type' => 'application/x-y-z'}, ['Blabla']])
    esi_app = Rack::Embed.new(mock_app)

    assert_same_response(mock_app, esi_app)
  end

  def test_html
    app = Rack::URLMap.new({
      '/'      => const([200, {'Content-Type' => 'text/html'}, ['<img src="/image"/>']]),
      '/image' => const([200, {'Content-Type' => 'image/png'}, ['image_data']])
    })

    esi_app = Rack::Embed.new(app)
    assert_equal ['<img src="data:image/png;base64,aW1hZ2VfZGF0YQ=="/>'], esi_app.call('SCRIPT_NAME' => '', 'PATH_INFO' => '/', 'HTTP_USER_AGENT' => 'WebKit')[2]
  end

  def test_css
    app = Rack::URLMap.new({
      '/'      => const([200, {'Content-Type' => 'text/css'}, ['background: url(/image)']]),
      '/image' => const([200, {'Content-Type' => 'image/png'}, ['image_data']])
    })

    esi_app = Rack::Embed.new(app)
    assert_equal ['background: url(data:image/png;base64,aW1hZ2VfZGF0YQ==)'], esi_app.call('SCRIPT_NAME' => '', 'PATH_INFO' => '/', 'HTTP_USER_AGENT' => 'WebKit')[2]
  end

  def test_threaded
    app = Rack::URLMap.new({
      '/'      => const([200, {'Content-Type' => 'text/css'}, ['background: url(/image)']]),
      '/image' => const([200, {'Content-Type' => 'image/png'}, ['image_data']])
    })

    esi_app = Rack::Embed.new(app, :threaded => true)
    assert_equal ['background: url(data:image/png;base64,aW1hZ2VfZGF0YQ==)'], esi_app.call('SCRIPT_NAME' => '', 'PATH_INFO' => '/', 'HTTP_USER_AGENT' => 'WebKit')[2]
  end

  def test_threaded_timeout
    app = Rack::URLMap.new({
      '/'      => const([200, {'Content-Type' => 'text/css'}, ['background: url(/image)']]),
      '/image' => proc { sleep 2 }
    })

    esi_app = Rack::Embed.new(app, :threaded => true, :timeout => 1)
    assert_equal ['background: url(/image)'], esi_app.call('SCRIPT_NAME' => '', 'PATH_INFO' => '/', 'HTTP_USER_AGENT' => 'WebKit')[2]
  end

  def test_too_large
    app = Rack::URLMap.new({
      '/'      => const([200, {'Content-Type' => 'text/css'}, ['background: url(/image)']]),
      '/image' => const([200, {'Content-Type' => 'image/png'}, ['bla' * 1024]])
    })

    esi_app = Rack::Embed.new(app)
    assert_equal ['background: url(/image)'], esi_app.call('SCRIPT_NAME' => '', 'PATH_INFO' => '/', 'HTTP_USER_AGENT' => 'WebKit')[2]
  end

  def test_file
    app = Rack::URLMap.new({
      '/'      => const([200, {'Content-Type' => 'text/css'}, ['background: url(/image)']]),
      '/image' => const([200, {'Content-Type' => 'image/png'}, File.open('test/test.image')])
    })

    esi_app = Rack::Embed.new(app)
    assert_equal ['background: url(data:image/png;base64,VGhpcyBpcyBhIHRlc3QgaW1hZ2U=)'],
    esi_app.call('SCRIPT_NAME' => '', 'PATH_INFO' => '/', 'HTTP_USER_AGENT' => 'WebKit')[2]
  end

  def test_invalid_browser
    app = Rack::URLMap.new({
      '/'      => const([200, {'Content-Type' => 'text/css'}, ['background: url(/image)']]),
      '/image' => const([200, {'Content-Type' => 'image/png'}, ['image_data']])
    })

    esi_app = Rack::Embed.new(app)
    assert_equal ['background: url(/image)'], esi_app.call('SCRIPT_NAME' => '', 'PATH_INFO' => '/', 'HTTP_USER_AGENT' => 'MSIE')[2]
  end

  private

  def const(value)
    lambda { |*_| value }
  end

  def assert_same_response(a, b)
    x = a.call({'HTTP_USER_AGENT' => 'WebKit'})
    y = b.call({'HTTP_USER_AGENT' => 'WebKit'})

    assert_equal(x,           y)
    assert_equal(x.object_id, y.object_id)
  end
end
