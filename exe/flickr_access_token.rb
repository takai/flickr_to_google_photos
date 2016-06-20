#!/usr/bin/env ruby -I lib

require 'bundler'
Bundler.require(:default)

require 'dotenv'
require 'flickraw'

Dotenv.load

FlickRaw.api_key       = ENV['FLICKR_CONSUMER_KEY']
FlickRaw.shared_secret = ENV['FLICKR_CONSUMER_SECRET']

@flickr = FlickRaw::Flickr.new
token = @flickr.get_request_token
auth_url = @flickr.get_authorize_url(token['oauth_token'])

system("open #{auth_url}")

print "code: "
verify = gets.strip

@flickr.get_access_token(token['oauth_token'],
                         token['oauth_token_secret'],
                         verify)
login = @flickr.test.login

puts <<-EOF

You are now authenticated as #{login.username}.
Put the following lines in your .env file.

FLICKR_ACCESS_TOKEN=#{@flickr.access_token}
FLICKR_ACCESS_TOKEN_SECRET=#{@flickr.access_secret}
EOF
