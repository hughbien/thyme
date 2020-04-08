require "../thyme"

# Handles returning formatted strings presented to the end user.
module Thyme::Format
  extend self

  # Returns formatted timer string for Tmux's status. Note that suffix is a parameter here
  # so we can cache the repeat_suffix outside of the seconds loop, since it only gets re-calculated
  # after a pomodoro/break ends -- while the rest of the status is updated per second.
  def status(total_seconds : Int64, suffix : String, on_break : Bool, config : Config)
    seconds = total_seconds % 60
    with_color(
      "#{(total_seconds / 60).to_i}:#{seconds >= 10 ? seconds : "0#{seconds}"}#{suffix}",
      tmux_color(total_seconds, on_break, config)
    )
  end

  # Returns repeat string to tell user which pomodoro they're currently on and how many
  # there are in total. If repeat is off, return a blank string.
  def repeat_suffix(repeat_index : UInt32, repeat_total : UInt32)
    if repeat_total == 1
      ""
    elsif repeat_total == 0 # unlimited
      " (#{repeat_index})"
    else
      " (#{repeat_index}/#{repeat_total})"
    end
  end

  # Wraps a string with a Tmux template for colors.
  def with_color(text : String, color : String)
    "#[fg=#{color}]#{text}#[default]"
  end

  # Determines which color to use for the current time: break, warning, or default.
  def tmux_color(total_seconds : Int64, on_break : Bool, config : Config)
    if on_break
      config.color_break
    elsif total_seconds <= config.timer_warning
      config.color_warning
    else
      config.color_default
    end
  end
end
