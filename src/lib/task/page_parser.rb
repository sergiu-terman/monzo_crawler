module Task
  class PageParser

    def initialize(page, publisher,
                   link_extractor=Aux::LinkExtractor.new,
                   content_reader=Aux::FileManager.new)
      @page = page
      @publisher = publisher
      @content_reader = content_reader
      @link_extractor = link_extractor
    end

    def run
      begin
        run_internal
      rescue Exception => e
        Aux::Log.error(e.message)
      end
    end

    def run_internal
      Aux::Log.info("Started to parse #{@page.url}")
      start = Time.now

      content = @content_reader.read(@page.download_name)
      links = @link_extractor.extract(content)
      process_links(links)
      @page.record_parsed!

      elapsed = (Time.now - start).truncate(3)
      Aux::Log.info("Finished to parse #{@page.url} (#{elapsed}s)")
    end

    def process_links(links)
      sanitize_links(links).each do |link|
        save_link(link)
      end
    end

    def sanitize_links(links)
      domain_filter = @page.domain_filter
      regex = Regexp.new("^((http:\/\/|https:\/\/)?(www\.)?#{domain_filter}).*")

      # same urls that have different strings after '#' should
      # treated as the same url
      links
        .map{ |l| l.split("#")[0] }
        .to_set
        .to_a
        .select{ |l| regex.match(l) }
    end

    def save_link(link)
      begin
        new_p = Model::Page.create(url: link, domain: @page.domain)
        @publisher.publish(new_p)
        Model::PageToPage.create(source: @page, destination: new_p)
      rescue Sequel::UniqueConstraintViolation
        # it's okay
      end
    end
  end
end
