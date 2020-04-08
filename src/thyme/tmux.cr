require "../thyme"

enum Thyme::StatusAlign
  Left
  Right

  def alignment
    to_s.downcase
  end
end

abstract class Thyme::Tmux
  private getter config : Config

  def initialize(@config)
  end

  abstract def set_status(status : String)
  abstract def reset_status

  def self.for(config : Config)
    if config.status_file
      TmuxFile.new(config)
    else
      TmuxMessage.new(config)
    end
  end
end

class Thyme::TmuxMessage < Thyme::Tmux
  @key : String
  @original : String

  def initialize(@config)
    super
    @key = "status-#{config.status_align.alignment}"
    @original = fetch_status
  end

  def set_status(status)
    `tmux set-option -g #{@key} "#{status}"`
  end

  def reset_status
    set_status(@original)
  end

  private def fetch_status
    parts = `tmux show-options -g | grep #{@key}`.split("\n").map do |line|
      line.split(" ", 2)
    end.find do |parts|
      parts.first == @key
    end
    parts.nil? ? "" : parts.last
  end
end

class Thyme::TmuxFile < Thyme::Tmux
  def set_status(status)
    File.write(status_file, status)
  end

  def reset_status
    File.delete(status_file)
  end

  private def status_file
    config.status_file.not_nil!
  end
end
