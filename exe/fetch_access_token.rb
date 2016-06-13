#!/usr/bin/env ruby -I lib

require 'net/http'

class Net::HTTP
  alias :create :initialize

  def initialize(*args)
    create(*args)
    self.set_debug_output $stderr
    $stderr.sync = true
  end
end

require 'bundler'
Bundler.setup(:default)

require 'dotenv'
require 'oauth'

Dotenv.load

FLICKR_API   = 'https://www.flickr.com/services'
CALLBACK_URL = "oob"

consumer = OAuth::Consumer.new(ENV['FLICKR_KEY'], ENV['FLICKR_SECRET'], site: FLICKR_API)
request_token = consumer.get_request_token(oauth_callback: CALLBACK_URL)

url = request_token.authorize_url(oauth_callback: CALLBACK_URL)
`open "#{url}"`

print 'oauth verifier: '
oauth_verifier = gets.chomp

session = {}
session[:oauth_token] = request_token.token
session[:oauth_token_secret] = request_token.secret

request_token = OAuth::RequestToken.from_hash(consumer, session)
access_token = request_token.get_access_token(oauth_verifier: oauth_verifier)
