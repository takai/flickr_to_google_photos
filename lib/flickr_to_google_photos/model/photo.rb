module FlickrToGooglePhotos
  module Model
    class Photo < ActiveRecord::Base
      def download
        Util::Downloader.download(url)
        touch(:downloaded_at)
      end
    end
  end
end
