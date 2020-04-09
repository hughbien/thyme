require "../thyme"
require "toml"

enum Thyme::HookEvent
  Before
  After
  BeforeBreak
  AfterBreak
  BeforeAll
  AfterAll
end

class Thyme::Hook
  getter name : String
  getter events : Array(HookEvent)

  private getter command : String

  def initialize(@name : String, @events : Array(HookEvent), @command : String)
  end

  def call(hooks_args : NamedTuple)
    cmd = command
    hooks_args.each do |key, value|
      cmd = cmd.sub("\#{#{key}}", value)
    end
    output = `#{cmd}`
    print(output) unless output.empty?
  rescue error : Exception
    raise Error.new("Hook `#{name}` with command `#{cmd}` failed: #{error}")
  end

  def self.parse(name : String, hook : TOML::Table)
    self.new(
      name,
      parse_events(name, hook),
      parse_command(name, hook)
    )
  end

  private def self.parse_events(name, hook : TOML::Table)
    if event = hook["events"].as?(String)
      [HookEvent.parse(event)]
    else
      hook["events"].as(Array(TOML::Type)).map { |e| HookEvent.parse(e.as(String)) }
    end
  rescue KeyError
    raise Error.new("Hook `#{name}` is missing `events` in `#{Config::THYMERC_FILE}`")
  rescue ArgumentError | TypeCastError
    raise Error.new("Hook `#{name}` has invalid `events` in `#{Config::THYMERC_FILE}`: #{hook["events"]}")
  end

  private def self.parse_command(name, hook : TOML::Table)
    hook["command"].as(String)
  rescue KeyError
    raise Error.new("Hook `#{name}` is missing `command` in `#{Config::THYMERC_FILE}`")
  rescue TypeCastError
    raise Error.new("Hook `#{name}` has invalid `command` in `#{Config::THYMERC_FILE}`: #{hook["command"]}")
  end
end
