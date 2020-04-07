require "../thyme"

class Thyme::Timer
  private getter tmux : Tmux
  private getter start_time : Time
  private getter end_time : Time

  @stop : Bool = false
  @pause_time : Time | Nil
  @repeat_total : Int32 = 1

  def initialize
    @tmux = Tmux.new
    @start_time = Time.local
    @end_time = @start_time + (25*60).seconds
  end

  def run
    repeat_index = 1
    while @repeat_total == 0 || repeat_index <= @repeat_total
      break if @stop

      run_single(repeat_index)
      run_single(repeat_index, true) unless repeat_index == @repeat_total
      repeat_index += 1
    end
    tmux.set_status("")
  end

  def run_single(repeat_index, on_break = false)
    return if @stop

    @end_time = Time.local + ((on_break ? 5 : 25) * 60).seconds
    while Time.local < end_time
      if @stop
        tmux.set_status("")
        return
      end

      tmux.set_status(format(time_remaining, repeat_index)) unless @pause_time
      sleep(1)
    end
  end

  def stop
    @stop = true
  end

  def toggle
    if @pause_time # unpausing, set new end_time
      delta = Time.local - @pause_time.not_nil!
      @end_time = @end_time + delta
      @pause_time = nil
    else # pausing
      @pause_time = Time.local
    end
  end

  private def time_remaining
    end_time - Time.local
  end

  private def format(span : Time::Span, repeat_index)
    seconds = span.seconds >= 10 ? span.seconds : "0#{span.seconds}"
    "#{span.minutes}:#{seconds}#{format_repeat(repeat_index)}"
  end

  private def format_repeat(repeat_index)
    if @repeat_total == 1
      ""
    elsif @repeat_total == 0 # unlimited
      " (#{repeat_index})"
    else
      " (#{repeat_index}/#{@repeat_total})"
    end
  end
end
