require "../thyme"

class Thyme::Tmux
  def set_status(status)
    `tmux set-option -g status-right "#{status}"`
  end
end
