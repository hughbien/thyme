require "../thyme"

module Thyme::Format
  extend self

  def status(total_seconds, suffix, on_break, config)
    seconds = total_seconds % 60
    with_color(
      "#{(total_seconds / 60).to_i}:#{seconds >= 10 ? seconds : "0#{seconds}"}#{suffix}",
      tmux_color(total_seconds, on_break, config)
    )
  end

  def repeat_suffix(repeat_index, repeat_total)
    if repeat_total == 1
      ""
    elsif repeat_total == 0 # unlimited
      " (#{repeat_index})"
    else
      " (#{repeat_index}/#{repeat_total})"
    end
  end

  def with_color(text, color)
    "#[fg=#{color}]#{text}#[default]"
  end

  def tmux_color(total_seconds, on_break, config)
    if on_break
      config.color_break
    elsif total_seconds <= config.timer_warning
      config.color_warning
    else
      config.color_default
    end
  end
end
