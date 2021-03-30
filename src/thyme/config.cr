require "../thyme"
require "yaml"

# Reads THYMERC_FILE, parses it, and stores its configuration. There should be one instance of
# Config which gets passed to all other classes. All values are optional.
class Thyme::Config
  THYMERC_FILE = "#{ENV["HOME"]}/.thymerc"

  private getter yaml : YAML::Any

  getter timer : UInt32 = (25 * 60).to_u32
  getter timer_break : UInt32 = (5 * 60).to_u32
  getter timer_warning : UInt32 = (5 * 60).to_u32
  getter repeat : UInt32 = 1

  getter color_default : String = "default"
  getter color_warning : String = "red"
  getter color_break : String = "default"

  getter status_align : StatusAlign = StatusAlign::Right
  getter status_override : Bool = true

  getter hooks : HookCollection = HookCollection.new
  getter options : Array(Option) = Array(Option).new

  # THYMERC_FILE is validated on initialization
  def initialize(input : YAML::Any)
    @yaml = as_nil?(input) ? YAML::Any.new(Hash(YAML::Any, YAML::Any).new) : input

    as_u32 = ->(v : YAML::Any) { v.as_i64.to_u32 }
    as_str = ->(v : YAML::Any) { v.as_s }
    as_bool = ->(v : YAML::Any) { v.as_bool }
    as_align = ->(v : YAML::Any) { StatusAlign.parse(v.as_s) }

    @timer = validate!("timer", as_u32) if has?("timer")
    @timer_break = validate!("timer_break", as_u32) if has?("timer_break")
    @timer_warning = validate!("timer_warning", as_u32) if has?("timer_warning")
    validate!("repeat", as_u32) if has?("repeat") # only sets if `-r` flag is given

    @color_default = validate!("color_default", as_str) if has?("color_default")
    @color_warning = validate!("color_warning", as_str) if has?("color_warning")
    @color_break = validate!("color_break", as_str) if has?("color_break")

    @status_align = validate!("status_align", as_align) if has?("status_align")
    @status_override = validate!("status_override", as_bool) if has?("status_override")

    @hooks = HookCollection.parse(yaml["hooks"]) if has?("hooks")
    parse_and_add_options if has?("options")
  end

  # Called when the --repeat flag is used. If no argument is given, falls back to
  # default used in THYMERC_FILE. If no default is there, set to 0 for unlimited repeats.
  def set_repeat(count : String | Nil = nil)
    if count && !count.to_s.strip.empty?
      @repeat = count.to_u32
    elsif has?("repeat")
      @repeat = yaml["repeat"].as_i64.to_u32
    else
      @repeat = 0
    end
  rescue error : ArgumentError
    raise Error.new("Invalid value for `repeat`: #{count}")
  end

  # Returns a Config from a YAML file
  def self.parse(file = THYMERC_FILE)
    contents = File.exists?(file) ? File.read(file) : ""
    yaml = if contents.strip == "" # empty configs will have empty key/values
      YAML::Any.new(Hash(YAML::Any, YAML::Any).new)
    else
      YAML.parse(contents)
    end
    raise ArgumentError.new("Config must be a key value map") unless yaml.as_h?
    Thyme::Config.new(yaml)
  rescue error : YAML::ParseException | ArgumentError
    raise Error.new("Unable to parse `#{THYMERC_FILE}` -- #{error.to_s}")
  end

  private def has?(key)
    !yaml[key]?.nil?
  end

  private def validate!(key, convert)
    convert.call(yaml[key])
  rescue error : TypeCastError | ArgumentError | OverflowError
    raise Error.new("Invalid value for `#{key}` in `#{THYMERC_FILE}`: #{yaml[key]}")
  end

  private def parse_and_add_options
    yaml["options"].as_h.each do |name, option|
      @options << Option.parse(name.as_s, option)
    end
  rescue TypeCastError
    raise Error.new("Invalid value for `options` in #{Config::THYMERC_FILE}")
  end

  private def as_nil?(any : YAML::Any) : Bool
    any.as_nil
    true
  rescue TypeCastError
    false
  end
end
