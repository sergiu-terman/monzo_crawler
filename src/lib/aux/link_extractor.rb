module Aux
  class LinkExtractor

    def extract(content)
      doc = Nokogiri::HTML(content)
      doc.css("[href]").map{ |l| l["href"] }
    end
  end
end
