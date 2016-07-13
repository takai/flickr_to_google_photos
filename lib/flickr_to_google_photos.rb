require 'flickraw'
require 'httpclient'
require 'concurrent'
require 'signet/oauth_2/client'
require 'picasa'
require 'active_record'
require 'yaml'

require 'dotenv'

Dotenv.load

require 'flickr_to_google_photos/version'
require 'flickr_to_google_photos/util/downloader'

require 'flickr_to_google_photos/api/flickr'
require 'flickr_to_google_photos/api/google_photos'

require 'flickr_to_google_photos/model/album'
require 'flickr_to_google_photos/model/photo'

begin
  db = YAML.load_file(File.join(__dir__, '../config/database.yml'))
  ActiveRecord::Base.establish_connection(db[ENV['APP_ENV'] || 'test'])

  if ENV.has_key?('INIT_DB')
    ddls = File.read(File.join(__dir__, '../config/ddl.sql'))
    ddls.gsub(/\n/, '').split(';').each do |ddl|
      ActiveRecord::Base.connection.execute(ddl)
    end
  end
rescue => e
  abort("Initialization error: #{e.message}")
end
