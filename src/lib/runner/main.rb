module Runner
  module Main
    class << self
      def run
        Aux::Log.info("Starting the crawler program")
        Task::Orchestrator.new(monzo_domain).run
      end

      def generate_graph
        Task::Graphgen.new(monzo_domain).run
      end



      # The crawler could deal with any domain and doesn't have any
      # code custom to the Monzo website. The domain should be an input argument.
      # For the purpose of the assignment resotring to the only monzo hardcoded bit here.
      def monzo_domain
        if Model::Domain.count == 0
          return Model::Domain.create(
            name: "monzo",
            domain_filter: "monzo.com",
            seed: "https://monzo.com",
          )
        end
        Model::Domain.find(name: "monzo")
      end
    end


  end
end
