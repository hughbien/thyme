require "../thyme"

class Thyme::Command
  private getter args : Array(String)
  private getter io : IO

  def initialize(@args = ARGV, @io = STDOUT)
  end

  def run
    Thyme::Timer.new.run
  end
end
