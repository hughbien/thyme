require "../thyme"
require "toml"

# Wraps the option extension in THYMERC_FILE configuration. Used by end users to extend Thyme with
# their own options and commands.
class Thyme::Option
  getter name : String
  getter flag : String
  getter flag_long : String
  getter description : String

  private getter command : String

  def initialize(
    @name : String,
    @flag : String,
    @flag_long : String,
    @description : String,
    @command : String
  )
  end

  # Calls `#command` as a system command. Replaces placeholders with actual values:
  # `#{flag}` - value given to a flag
  # `#{args}` - additional arguments given to the `thyme` command
  def call(option_args : NamedTuple)
    cmd = command
    option_args.each do |key, value|
      cmd = cmd.sub("\#{#{key}}", value)
    end
    output = `#{cmd}`
    print(output) unless output.empty?
  end

  # Parses the TOML table and returns a Thyme::Option. All fields are required.
  def self.parse(name, toml)
    h = toml.as(Hash(String, TOML::Type))
    self.new(
      name,
      validate!(h, name, "flag"),
      validate!(h, name, "flag_long"),
      validate!(h, name, "description"),
      validate!(h, name, "command")
    )
  end

  # Verifies key is available and is a String.
  def self.validate!(toml, name, key)
    toml[key].as(String)
  rescue KeyError
    raise Error.new("Option `#{name}` is missing `#{key}` in `#{Config::THYMERC_FILE}`")
  rescue TypeCastError
    raise Error.new("Option `#{name}` has invalid `#{key}` in `#{Config::THYMERC_FILE}`")
  end
end
