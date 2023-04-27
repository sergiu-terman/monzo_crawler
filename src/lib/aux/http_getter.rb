module Aux
  class HttpGetter
    def get(url)
      HTTParty.get(url)
    end
  end
end
