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
    tmp_path = nil
    Tempfile.open(File.basename(@path)) do |f|
      @lines.each do |line|
        f.write(line)
        f.write("\n")
      end
      tmp_path = f.path
    end
    if backup_suffix
      FileUtils.mv @path, @path + backup_suffix
    else
      FileUtils.rm @path
    end
    FileUtils.mv tmp_path, @path
  end
end
