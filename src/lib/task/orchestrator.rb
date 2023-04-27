module Task
  class Orchestrator

    def initialize(domain)
      @domain = domain
    end


    def run
      prepare_seed_page_if_missing
      initiate_execution
    end


    private

    def prepare_seed_page_if_missing
      unless @domain.has_pages?
        Model::Page.create(url: @domain.seed, domain: @domain)
      end
    end


    def initiate_execution
      download_executor = Task::Executor.new("download")
      parse_executor = Task::Executor.new("parse")

      download_publisher = Task::Publisher.new(Task::PageDownloader, download_executor)
      parse_publisher = Task::Publisher.new(Task::PageParser, parse_executor)

      download_publisher.next_publisher = parse_publisher
      parse_publisher.next_publisher = download_publisher


      publish_initial_tasks(download_publisher, @domain.pages_to_download)
      publish_initial_tasks(parse_publisher, @domain.pages_to_parse)

      download_executor.run
      parse_executor.run


      # waiting for an eternity
      download_executor.wait
      parse_executor.wait
    end

    def publish_initial_tasks(publisher, pages)
      pages.each do |p|
        publisher.publish(p)
      end
    end

  end
end
