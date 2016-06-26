module FlickrToGooglePhotos
  module Util
    class Downloader
      DOWNLOAD_CONCURRENCY = ENV['DOWNLOAD_CONCURRENCY'] || 3

      def self.download(url)
        @downloader ||= new
        @downloader.push(url)
      end

      def initialize
        @queue = Queue.new
        @http = HTTPClient.new
        @pool = Concurrent::FixedThreadPool.new(DOWNLOAD_CONCURRENCY)
      end

      def start
        DOWNLOAD_CONCURRENCY.times do
          @pool.post do
            while url = @queue.pop
              break unless url

              path = File.join(Dir.tmpdir, File.basename(url))
              File.binwrite(path, @http.get(url).body)
            end
          end
        end
      end

      def stop
        @queue.num_waiting.times do
          @queue.push(nil)
        end
      end

      def push(url)
        @queue.push(url)
      end
    end
  end
end