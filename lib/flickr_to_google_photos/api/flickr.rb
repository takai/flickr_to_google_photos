require 'flickraw'

module FlickrToGooglePhotos
  class Flickr
    include Enumerable

    FLICKR_API = 'https://www.flickr.com/services'
    PER_PAGE = 500

    def initialize(consumer_key, consumer_secret, access_token, access_secret)
      @flickr = ::FlickRaw::Flickr.new(api_key: consumer_key, shared_secret: consumer_secret)
      @flickr.access_token = access_token
      @flickr.access_secret = access_secret
    end

    def each_albums
      return to_enum(:each_albums) unless block_given?

      photosets_list.each do |set|
        model = FlickrToGooglePhotos::Model::Album.new(flickr_id: set.id,
                                                       title: set.title,
                                                       description: set.description)
        yield(model)
      end
    end

    def each_photos_by_album(album)
      return to_enum(:each_photos_by_album, album) unless block_given?

      photosets_photos(album.flickr_id).photo.each do |photo|
        model = build_photo_model(photo)
        model.album = album
        yield(model)
      end
    end

    def each_photos_not_in_set
      return to_enum(:each_photos_not_in_set) unless block_given?

      photos_not_in_set.each do |photo|
        model = build_photo_model(photo)
        yield(model)
      end
    end

    def each_photos
      return to_enum(:each_photos) unless block_given?

      count = people_info['photos']['count']

      count.quo(PER_PAGE).ceil.times do |i|
        people_photos(page: i + 1).each do |photo|
          model = build_photo_model(photo)
          yield(model)
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

    def photos_not_in_set(page: 1, photos: [])
      resp = @flickr.photos.getNotInSet(page: page, per_page: PER_PAGE)
      if resp['pages'] < page
        photos + resp.photo
      else
        photos_not_in_set(page: page + 1, photos: resp.photo)
      end
    end

    def photosets_list
      @_photosets_list ||= @flickr.photosets.getList
    end

    def photosets_photos(flickr_photoset_id)
      @_photosets_photos ||= @flickr.photosets.getPhotos(photoset_id: flickr_photoset_id)
    end

    def build_photo_model(photo)
      info = photos_info(photo)
      FlickrToGooglePhotos::Model::Photo.new(title: info.title,
                                             url: FlickRaw.url_o(info),
                                             public: info.visibility.ispublic)
    end
  end
end
