module Aux
  class HTTPGetter
    def get(url)
      HTTParty.get(url)
    end
  end
end
