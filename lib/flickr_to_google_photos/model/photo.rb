module FlickrToGooglePhotos
  module Model
    class Photo < ActiveRecord::Base
      belongs_to :album

      scope(:in_album, -> () { where.not(album: nil) })
    end
  end
end
