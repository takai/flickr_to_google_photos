module FlickrToGooglePhotos
  module Model
    class Album < ActiveRecord::Base
      has_many :photos
    end
  end
end
