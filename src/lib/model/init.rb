def get_db
  is_test = ENV["RACK_ENV"] == "test"

  db_file = is_test ? "test.db" : "prod.db"
  db_path = "#{ENV['WORKDIR']}/storage/#{db_file}"

  if is_test
    FileUtils.rm(db_path, force: true)
  end

  FileUtils.touch(db_path)
  Sequel.connect("sqlite://#{db_path}")
end

# Normally this sould be done in a migration system
# For now sticking with simply creating the table.
# will require to nuke the DB.
def create_tables!
  db = get_db

  db.create_table? :domains do
    primary_key :id

    String :name
    String :domain_filter
    String :seed
  end

  db.create_table? :pages do
    primary_key :id
    foreign_key :domain_id, :domains

    String :url, unique: true

    FalseClass :is_downloaded
    DateTime :downloaded_at
    String :downloaded_path
    Integer :download_attempt

    FalseClass :is_parsed
    DateTime :parsed_at

    DateTime :created_at
    DateTime :updated_at
  end

  db.create_table? :page_to_pages do
    primary_key :id
    foreign_key :source_id, :pages
    foreign_key :destination_id, :pages
    unique [:source_id, :destination_id]
  end
end

create_tables!
