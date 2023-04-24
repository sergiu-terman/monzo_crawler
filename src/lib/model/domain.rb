module Model
  class Domain < Sequel::Model
    one_to_many :pages
  end
end
