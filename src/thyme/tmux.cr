require "../thyme"

class Thyme::Tmux
  getter config : Config
  getter align : String = "right"

  def initialize(@config)
    @align = "left" if @config.status_align == "left"
  end

  def set_status(status)
    `tmux set-option -g status-#{align} "#{status}"`
  end
end
