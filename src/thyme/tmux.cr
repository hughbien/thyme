require "../thyme"

enum StatusAlign
  Left
  Right

  def alignment
    to_s.downcase
  end
end

class Thyme::Tmux
  private getter config : Config

  def initialize(@config)
  end

  def set_status(status)
    `tmux set-option -g status-#{config.status_align.alignment} "#{status}"`
  end
end
