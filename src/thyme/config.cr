require "../thyme"
require "toml"

class Thyme::Config
  THYMERC_FILE = "#{ENV["HOME"]}/.thymerc"

  private getter toml : TOML::Table

  getter timer : UInt32 = (25 * 60).to_u32
  getter timer_break : UInt32 = (5 * 60).to_u32
  getter timer_warning : UInt32 = (5 * 60).to_u32
  getter repeat : UInt32 = 1

  getter color_default : String = "default"
  getter color_warning : String = "red"
  getter color_break : String = "default"

  getter status_align : StatusAlign = StatusAlign::Right
  getter status_file : String | Nil

  getter hooks : HookCollection = HookCollection.new
  getter options : Array(Option) = Array(Option).new

  def initialize(@toml : TOML::Table)
    as_u32 = ->(v : TOML::Type) { v.as(Int64).to_u32 }
    as_str = ->(v : TOML::Type) { v.as(String) }
    as_align = ->(v : TOML::Type) { StatusAlign.parse(v.as(String)) }

    @timer = validate!("timer", as_u32) if has?("timer")
    @timer_break = validate!("timer_break", as_u32) if has?("timer_break")
    @timer_warning = validate!("timer_warning", as_u32) if has?("timer_warning")
    validate!("repeat", as_u32) if has?("repeat") # only sets if `-r` flag is given

    @color_default = validate!("color_default", as_str) if has?("color_default")
    @color_warning = validate!("color_warning", as_str) if has?("color_warning")
    @color_break = validate!("color_break", as_str) if has?("color_break")

    @status_align = validate!("status_align", as_align) if has?("status_align")
    @status_file = validate_file!("status_file", as_str) if has?("status_file")

    @hooks = HookCollection.parse(toml["hooks"]) if has?("hooks")
    parse_and_add_options if has?("options")
  end

  def set_repeat(count : String | Nil = nil)
    if count
      @repeat = count.to_u32
    elsif has?("repeat")
      @repeat = toml["repeat"].as(Int64).to_u32
    else
      @repeat = 0
    end
  rescue error : ArgumentError
    raise Error.new("Invalid value for `repeat`: #{count}")
  end

  def self.parse(file = THYMERC_FILE)
    toml = TOML.parse(File.exists?(file) ? File.read(file) : "")
    Thyme::Config.new(toml)
  rescue error : TOML::ParseException
    raise Error.new("Unable to parse `#{THYMERC_FILE}` -- #{error.to_s}")
  end

  private def has?(key)
    toml.has_key?(key)
  end

  private def validate!(key, convert)
    convert.call(toml[key])
  rescue error : TypeCastError | ArgumentError
    raise Error.new("Invalid value for `#{key}` in `#{THYMERC_FILE}`: #{toml[key]}")
  end

  private def validate_file!(key, convert)
    path = validate!(key, convert)
    dir = File.dirname(path)
    raise Error.new("Invalid value for `#{key}` in `#{THYMERC_FILE}` -- `#{dir}` does not exist") unless Dir.exists?(dir)
    path
  end

  private def parse_and_add_options
    toml["options"].as(Hash(String, TOML::Type)).each do |name, option|
      @options << Option.parse(name, option)
    end
  rescue TypeCastError
    raise Error.new("Invalid value for `options` in #{Config::THYMERC_FILE}")
  end
end
