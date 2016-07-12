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
albums.map(&:save)
albums.each do |album|
  puts "Importing '#{album.title}'..."
  flickr.each_photos_by_album(album).map(&:save)
end

flickr.each_photos_not_in_set.map(&:save)
