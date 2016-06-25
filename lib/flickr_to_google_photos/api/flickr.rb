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

    def each_photos
      return to_enum(:each) unless block_given?

      count = people_info['photos']['count']

      count.quo(PER_PAGE).ceil.times do |i|
        people_photos(page: i + 1).each do |photo|
          info = photos_info(photo)
          model = FlickrToGooglePhotos::Model::Photo.new(title: info.title,
                                                         url: FlickRaw.url_o(info),
                                                         public: info.visibility.ispublic)

          yield model
        end
      end
    end

    private

    def login
      @_login ||= @flickr.test.login
    end

    def people_info
      @_info ||= @flickr.people.getInfo(user_id: login['id'])
    end

    def people_photos(page:)
      @flickr.people.getPhotos(user_id: login['id'],
                               per_page: PER_PAGE,
                               page: page)
    end

    def photos_info(photo)
      @flickr.photos.getInfo(photo_id: photo.id, secret: photo.secret)
    end
  end
end
