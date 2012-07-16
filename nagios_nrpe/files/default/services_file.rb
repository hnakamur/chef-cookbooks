require 'fileutils'
require 'tempfile'
require "#{File.dirname(__FILE__)}/text_file.rb"

class ServicesFile < TextFile
  def self.load()
    ServicesFile.new('/etc/services').load
  end

  def index_for_port(port)
    lines.index do |line|
      m = /^\S+\s+(\d+)/.match(line)
      m && m[1].to_i > port
    end
  end
end
