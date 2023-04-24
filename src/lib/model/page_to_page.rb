module Model
  class PageToPage < Sequel::Model
    many_to_one :source, class: Model::Page
    many_to_one :destination, class: Model::Page
  end
end
