module Model
  class Page < Sequel::Model
    plugin :timestamps

    many_to_many :linked_to, class: self, join_table: :page_to_pages,
      left_key: :source_id, right_key: :destination_id
    many_to_one :domain

    def record_failed_download!
      self.download_failed = true

      mark_as_downloaded
      save
    end

    def record_download!(file_name)
      self.download_name = file_name

      mark_as_downloaded
      save
    end

    def domain_name
      domain.name
    end

    private

    def mark_as_downloaded
      self.is_downloaded = true
      self.downloaded_at = Time.now
    end
  end
end
