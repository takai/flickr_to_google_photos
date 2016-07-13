#!/usr/bin/env ruby -I lib

require 'bundler'
Bundler.require(:default)

require_relative '../lib/flickr_to_google_photos'

flickr = FlickrToGooglePhotos::Flickr.new(ENV['FLICKR_CONSUMER_KEY'],
                                          ENV['FLICKR_CONSUMER_SECRET'],
                                          ENV['FLICKR_ACCESS_TOKEN'],
                                          ENV['FLICKR_ACCESS_TOKEN_SECRET'])

puts "Importing albums..."
albums = flickr.each_albums
albums.each do |album|
  unless album.build_at?
    puts "Importing '#{album.title}'..."
    album.photos.delete_all
    flickr.each_photos_by_album(album).map(&:save)
    album.touch(:build_at)
  end
end

flickr.each_photos_not_in_set.map(&:save)
