require "../thyme"
require "option_parser"

class Thyme::Command
  private getter args : Array(String)
  private getter io : IO

  def initialize(@args = ARGV, @io = STDOUT)
  end

  def run
    config = Config.parse
    # see https://github.com/crystal-lang/crystal/issues/5338
    # OptionParser can't handle optional flag argument for now
    config.set_repeat if args.any?(Set{"-r", "--repeat"})

    parser = OptionParser.parse(args) do |parser|
      parser.banner = "Usage: thyme [options]"

      parser.on("-h", "--help", "print help message") { print_help(parser); exit }
      parser.on("-v", "--version", "print version") { print_version; exit }
      parser.on("-s", "--stop", "stop timer") { stop; exit }
      parser.on("-r", "--repeat [count]", "repeat timer") { |r| config.set_repeat(r) }
    end

    if args.size > 0
      print_help(parser)
    elsif ProcessHandler.running?
      SignalHandler.send_toggle
    else
      start(config)
    end
  rescue error : OptionParser::InvalidOption | Error
    io.puts(error)
  end

  private def start(config : Config)
    #Daemon.start!
    ProcessHandler.write_pid

    timer = Timer.new(config)
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
