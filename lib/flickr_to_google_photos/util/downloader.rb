module FlickrToGooglePhotos
  module Util
    class Downloader
      DOWNLOAD_CONCURRENCY = ENV['DOWNLOAD_CONCURRENCY'] || 3

      SAVE_TO_TEMP = -> (body) do
        tmp = Tempfile.new('f2g')
        File.binwrite(tmp.path, body)
      end

      def self.download(url, with: SAVE_TO_TEMP)
        @downloader ||= new
        @downloader.push(url, with: with)
        @downloader.start
      end

      def initialize
        @queue = Queue.new
        @pool = Concurrent::FixedThreadPool.new(DOWNLOAD_CONCURRENCY)
      end

      def start
        DOWNLOAD_CONCURRENCY.times do
          @pool.post do
            while command = @queue.pop
              begin
                url, proc = *command
                break unless url

                body = HTTPClient.new.get(url).body

                proc.call(body)
              rescue e
                warn(e.message)
              end
            end
          end
        end
      end

      def stop
        @queue.num_waiting.times do
          @queue.push(nil)
        end
      end

      def push(url, with: SAVE_TO_TEMP)
        @queue.push([url, with])
      end
    end
  end
end
