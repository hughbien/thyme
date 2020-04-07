require "../thyme"
require "toml"

class Thyme::Config
  THYMERC_FILE = "#{ENV["HOME"]}/.thymerc"

  getter toml : TOML::Table

  getter timer : UInt32 = (25 * 60).to_u32
  getter timer_break : UInt32 = (5 * 60).to_u32
  getter timer_warning : UInt32 = (5 * 60).to_u32
  getter repeat : UInt32 = 1

  getter color_default : String = "default"
  getter color_warning : String = "red"
  getter color_break : String = "default"

  getter status_align : String = "right"
  getter status_file : String | Nil

  def initialize(@toml : TOML::Table)
    as_u32 = ->(v : TOML::Type) { v.as(Int64).to_u32 }
    as_str = ->(v : TOML::Type) { v.as(String) }

    @timer = validate!("timer", as_u32) if has?("timer")
    @timer_break = validate!("timer_break", as_u32) if has?("timer_break")
    @timer_warning = validate!("timer_warning", as_u32) if has?("timer_warning")
    @repeat = validate!("repeat", as_u32) if has?("repeat")

    @color_default = validate!("color_default", as_str) if has?("color_default")
    @color_warning = validate!("color_warning", as_str) if has?("color_warning")
    @color_break = validate!("color_break", as_str) if has?("color_break")

    @status_align = validate!("status_align", as_str) if has?("status_align")
    @status_file = validate!("status_file", as_str) if has?("status_file")
  end

  def self.parse(file = THYMERC_FILE)
    toml = TOML.parse(File.exists?(file) ? File.read(file) : "")
    Thyme::Config.new(toml)
  end

  private def has?(key)
    toml.has_key?(key)
  end

  private def validate!(key, convert)
    convert.call(toml[key])
  rescue error : TypeCastError
    raise Error.new("Invalid value for `#{key}` in `#{THYMERC_FILE}`: #{toml[key]}")
  end
end
