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
    `#{cmd}`
  end

  def self.parse(name : String, hook : TOML::Table)
    self.new(
      name,
      parse_events(name, hook),
      parse_command(name, hook)
    )
  end

  def self.parse_events(name, hook : TOML::Table)
    if event = hook["events"].as?(String)
      [HookEvent.parse(event)]
    else
      hook["events"].as(Array(TOML::Type)).map { |e| HookEvent.parse(e.as(String)) }
    end
  rescue KeyError
    raise Error.new("No events found for hook `#{name}` in `#{Config::THYMERC_FILE}`")
  rescue ArgumentError | TypeCastError
    raise Error.new("Invalid events for hook `#{name}` in `#{Config::THYMERC_FILE}`: #{hook["events"]}")
  end

  def self.parse_command(name, hook : TOML::Table)
    hook["command"].as(String)
  rescue KeyError
    raise Error.new("No command found for hook `#{name}` in `#{Config::THYMERC_FILE}`")
  rescue TypeCastError
    raise Error.new("Invalid command for hook `#{name}` in `#{Config::THYMERC_FILE}`: #{hook["command"]}")
  end
end
