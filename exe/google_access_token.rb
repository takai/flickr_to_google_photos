#!/usr/bin/env ruby -I lib

require 'bundler'
Bundler.require(:default)

require 'dotenv'
Dotenv.load

require 'signet/oauth_2/client'

client = Signet::OAuth2::Client.new(
  authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
  token_credential_uri: 'https://www.googleapis.com/oauth2/v3/token',
  redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
  client_id: ENV['GOOGLE_CLIENT_ID'],
  client_secret: ENV['GOOGLE_CLIENT_SECRET'],
  scope: 'http://picasaweb.google.com/data/',
)

auth_uri = client.authorization_uri(response_type: 'code')
system("open '#{auth_uri.to_s}'")

print "code: "
client.code = gets.strip

client.fetch_access_token!
puts <<-EOF

Put the following lines in your .env file or set environment variable.

GOOGLE_REFRESH_TOKEN=#{client.refresh_token}
EOF
