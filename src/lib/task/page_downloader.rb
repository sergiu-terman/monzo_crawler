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
      begin
        run_internal
      rescue Exception => e
        Aux::Log.error(e.message)
      end
    end

    def run_internal
      Aux::Log.info("Started to download #{@page.url}")
      start = Time.now

      res = @web_getter.get(@page.url)

      if res.code.to_s.start_with?("2")
        process_success(res.body)
      else
        process_failure
      end

      elapsed = (Time.now - start).truncate(3)
      Aux::Log.info("Finished to download #{@page.url} (#{elapsed}s)")
    end

    def process_failure
      @page.record_failed_download!
    end

    def process_success(content)
      file_name = "#{@page.domain_name}_#{SecureRandom.uuid}"

      @content_writer.write(file_name, content)
      @page.record_download!(file_name)
      @publisher.publish(@page)
    end

  end
end
