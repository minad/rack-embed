# Rack::Embed

Rack::Embed embeds small images via the data-url (base64) if the browser supports it.
This reduces http traffic.

# Installation

    gem sources -a http://gemcutter.org
    gem install rack-embed

# Usage

Add the following line to your rackup file:

    use Rack::Embed, :max_size => 1024

