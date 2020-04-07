require "../thyme"

class Thyme::Config
  THYMERC_FILE = "#{ENV["HOME"]}/.thymerc"

  getter timer : UInt32 = (25 * 60).to_u32
  getter timer_break : UInt32 = (5 * 60).to_u32
  getter timer_warning : UInt32 = (5 * 60).to_u32
  getter repeat : UInt32 = 1

  getter color_default : String = "default"
  getter color_warning : String = "red"
  getter color_break : String = "default"

  getter status_align : String = "left"
  getter status_file : String | Nil

  def initialize
  end

  def self.parse
    Thyme::Config.new
  end
end
