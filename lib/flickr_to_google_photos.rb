require 'flickraw'
require 'httpclient'
require 'concurrent'
require 'signet/oauth_2/client'
require 'picasa'
require 'active_record'
require 'yaml'

require 'dotenv'

Dotenv.load

require "flickr_to_google_photos/version"
require "flickr_to_google_photos/downloader"
require "flickr_to_google_photos/flickr"
require "flickr_to_google_photos/google_photos"

require 'flickr_to_google_photos/model/album'
require 'flickr_to_google_photos/model/photo'

begin
  db = YAML.load_file(File.join(__dir__, '../config/database.yml'))
  ActiveRecord::Base.establish_connection(db[ENV['environment'] || 'main'])

  ddls = File.read(File.join(__dir__, '../config/ddl.sql'))
  ddls.gsub(/\n/, '').split(';').each do |ddl|
    ActiveRecord::Base.connection.execute(ddl)
  end
rescue => e
  abort("Initialization error: #{e.message}")
end
