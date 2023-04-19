require 'sqlite3'
require 'sequel'
require 'pry'
require 'nokogiri'
require 'watir'
require 'require_all'
require 'pathname'

dirs = Pathname.new("#{ENV['WORKDIR']}/src/lib/")
  .children
  .select { |d| d.directory? }

dirs.each do |d|
  autoload_all d
end
