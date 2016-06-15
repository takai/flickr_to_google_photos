require 'flickraw'

module FlickrToGooglePhotos
  class Flickr
    include Enumerable

    FLICKR_API = 'https://www.flickr.com/services'
    PER_PAGE = 500

    def initialize(consumer_key, consumer_secret, access_token, access_secret)
      FlickRaw.api_key = consumer_key
      FlickRaw.shared_secret = consumer_secret

      @flickr = FlickRaw::Flickr.new
      @flickr.access_token = access_token
      @flickr.access_secret = access_secret
    end

    def each
      count = info['photos']['count']

      count.quo(PER_PAGE).ceil.times do |i|
        get_photos(page: i + 1).each do |photo|
          yield photo
        end
      end

      self
    end

    private
    def login
      @_login ||= @flickr.test.login
    end

    def info
      @_info ||= @flickr.people.getInfo(user_id: login['id'])
    end

    def get_photos(page:)
      @flickr.people.getPhotos(user_id: login['id'],
                               per_page: PER_PAGE,
                               page: page)
    end
  end
end
