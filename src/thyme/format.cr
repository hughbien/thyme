require "../thyme"

module Thyme::Format
  extend self

  def status(span : Time::Span, repeat_index, on_break, config)
    seconds = span.seconds >= 10 ? span.seconds : "0#{span.seconds}"
    with_color(
      "#{span.minutes}:#{seconds}#{repeat_suffix(repeat_index, config.repeat)}",
      tmux_color(span.total_seconds, on_break, config)
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

  def with_color(text, color = "default")
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
