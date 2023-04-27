require 'sqlite3'
require 'sequel'
require 'nokogiri'
require 'watir'
require 'zeitwerk'
require 'pathname'
require 'fileutils'
require 'thread/pool'
require 'httparty'
require 'securerandom'

require 'pry'
require 'pry-byebug'

require_relative 'model/init'

def autoload_libs
  loader = Zeitwerk::Loader.new
  loader.push_dir("#{ENV['WORKDIR']}/src/lib/")
  loader.setup
end

autoload_libs
