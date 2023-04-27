module Model
  class Domain < Sequel::Model
    one_to_many :pages

    def has_pages?
      pages.count > 0
    end

    def pages_to_download
      pages_dataset.where(is_downloaded: false).all
    end

    def pages_to_parse
      pages_dataset.where(is_downloaded: true)
        .where(is_parsed: false).all
    end
  end
end
