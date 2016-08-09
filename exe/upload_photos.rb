#!/usr/bin/env ruby -I lib

require 'bundler'
Bundler.require(:default)

require_relative '../lib/flickr_to_google_photos'

def new_photos
  FlickrToGooglePhotos::GooglePhotos.new(ENV['GOOGLE_USER_ID'],
                                         ENV['GOOGLE_CLIENT_ID'],
                                         ENV['GOOGLE_CLIENT_SECRET'],
                                         ENV['GOOGLE_REFRESH_TOKEN'])
end

photos = new_photos

puts "Start uploading..."
FlickrToGooglePhotos::Model::Photo.connection
FlickrToGooglePhotos::Model::Photo.where(uploaded_at: 0).each do |photo|
  begin
    puts "Fetching #{photo.url}..."
    binary = HTTPClient.new.get(photo.url).body
    puts "Uploading #{photo.url}..."
    photos.upload_photo(photo.album, photo, binary)
  rescue Picasa::ForbiddenError => e
    photos = new_photos
  rescue Picasa::BadRequestError, Encoding::CompatibilityError => e
    warn "[WARN] #{photo.url}: #{e.message}"
  end
end
