module Task
  class Graphgen

    def initialize(domain)
      @domain = domain
      @graph = GEXF::Graph.new(directed: true)
      @node_map = Hash.new
      @visited = Set.new


      start_node = Model::Page.where(url: domain.seed).first
      @queue = Queue.new([start_node])
    end

    def run

      while !@queue.empty?
        page = @queue.pop
        mark_as_visited(page)

        page.linked_to.each do |next_page|
          @graph.create_edge(n(page), n(next_page), directed: true)

          unless visited?(next_page)
            @queue.push(next_page)
          end
        end
      end

      File.open("#{ENV['WORKDIR']}/storage/graph.gexf", 'w') do |file|
        file.write(@graph.to_xml)
      end
    end

    def mark_as_visited(page)
      @visited.add(page.url)
    end

    def visited?(page)
      @visited.include?(page.url)
    end

    def n(page)
      url = page.url
      if @node_map.has_key?(url)
        return @node_map[url]
      end

      n = @graph.create_node(id: url, label: url)
      @node_map[url] = n
      n
    end
  end
end
