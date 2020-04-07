require "../thyme"
require "option_parser"

class Thyme::Command
  private getter args : Array(String)
  private getter io : IO

  def initialize(@args = ARGV, @io = STDOUT)
  end

  def run
    parser = OptionParser.parse(args) do |parser|
      parser.banner = "Usage: thyme [options]"

      parser.on("-h", "--help", "Print this help message") { print_help(parser); exit }
      parser.on("-v", "--version", "Print version") { print_version; exit }
      parser.on("-s", "--stop", "Stop timer") { stop; exit }
    end

    if args.size > 0
      print_help(parser)
    elsif ProcessHandler.running?
      SignalHandler.send_toggle
    else
      start
    end
  rescue error : OptionParser::InvalidOption | Error
    io.puts(error)
  end

  private def start
    #Daemon.start!
    ProcessHandler.write_pid

    config = Thyme::Config.parse
    timer = Thyme::Timer.new(config)
    SignalHandler.on_stop { timer.stop }
    SignalHandler.on_toggle { timer.toggle }
    timer.run
  rescue error : Error
    io.puts(error)
    ProcessHandler.delete_pid
  end

  private def stop
    SignalHandler.send_stop if ProcessHandler.running?
  ensure
    ProcessHandler.delete_pid
  end

  private def print_help(parser)
    io.puts(parser)
  end

  private def print_version
    io.puts(VERSION)
  end
end
