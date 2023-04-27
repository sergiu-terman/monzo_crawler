module Aux
  class DbUtil
    def self.clean!
      if ENV["RACK_ENV"] == "test"
        Model::PageToPage.dataset.delete
        Model::Page.dataset.delete
        Model::Domain.dataset.delete
      end
    end
  end
end
