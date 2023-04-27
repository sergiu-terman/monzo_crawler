module Task
  class PageDownloader

    def initialize(page, publisher,
                   web_getter=Aux::HttpGetter.new,
                   content_writer=Aux::FileManager.new)
      @page = page
      @publisher = publisher


      # mockable dependencies
      @web_getter = web_getter
      @content_writer = content_writer
    end

    def run
      res = @web_getter.get(@page.url)

      if res.code.to_s.start_with?("2")
        process_success(res.body)
      else
        process_failure
      end
    end

    def process_failure
      @page.record_failed_download!
    end

    def process_success(content)
      file_name = "#{@page.domain_name}_#{SecureRandom.uuid}"

      @content_writer.write(file_name, content)
      @page.record_download!(file_name)
      @publisher.publish(@page)
      Aux::Log.info("Successfully downloaded #{@page.url}")
    end

  end
end
