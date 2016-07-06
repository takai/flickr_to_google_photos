module FlickrToGooglePhotos
  module Model
    class Photo < ActiveRecord::Base
      belongs_to :album

      def download
        Util::Downloader.download(url)
        touch(:downloaded_at)
      end
    end
  end
end
