require 'fileutils'
require 'tempfile'

class TextFile
  attr_accessor :lines
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def load
    @lines = []
    File.open(path, "r") do |f|
      f.each_line{|line| @lines << line.chomp}
    end
    self
  end

  def self.load(path)
    TextFile.new(path).load
  end

  def save(backup_suffix=nil)
    tmpf = Tempfile.open(@path) do |f|
      @lines.each do |line|
        f.write(line)
        f.write("\n")
      end
      f
    end
    if backup_suffix
      FileUtils.mv @path, @path + backup_suffix
    else
      FileUtils.rm @path
    end
    FileUtils.mv tmpf, @path
  end
end
