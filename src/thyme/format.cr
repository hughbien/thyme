require "../thyme"

module Thyme::Format
  extend self

  def status(span : Time::Span, repeat_index, repeat_total, on_break, timer_warning)
    seconds = span.seconds >= 10 ? span.seconds : "0#{span.seconds}"
    with_color(
      "#{span.minutes}:#{seconds}#{repeat_suffix(repeat_index, repeat_total)}",
      tmux_color(span.total_seconds, on_break, timer_warning)
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

  def tmux_color(total_seconds, on_break, timer_warning)
    if on_break
      "default"
    elsif total_seconds <= timer_warning
      "red"
    else
      "default"
    end
  end
end
