require "../thyme"

module Thyme::Format
  extend self

  def status(span : Time::Span, repeat_index, repeat_total, on_break)
    seconds = span.seconds >= 10 ? span.seconds : "0#{span.seconds}"
    with_color(
      "#{span.minutes}:#{seconds}#{repeat_suffix(repeat_index, repeat_total)}",
      tmux_color(span.seconds, on_break)
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

  def tmux_color(seconds, on_break)
    if on_break
      "default"
    elsif seconds <= 5
      "red"
    else
      "default"
    end
  end
end
