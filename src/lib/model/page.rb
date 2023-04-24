module Model
  class Page < Sequel::Model
    plugin :timestamps

    many_to_many :linked_to, class: self, join_table: :page_to_pages,
      left_key: :source_id, right_key: :destination_id
    many_to_one :domain
  end
end
