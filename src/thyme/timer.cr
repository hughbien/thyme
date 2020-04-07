require "../thyme"

class Thyme::Timer
  private getter tmux : Tmux
  private getter start_time : Time
  private getter end_time : Time

  @stop : Bool = false
  @pause_time : Time | Nil
  @repeat_total : Int32 = 5

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

    @end_time = Time.local + ((on_break ? 1 : 2) * 5).seconds
    while Time.local < end_time
      if @stop
        tmux.set_status("")
        return
      end

      tmux.set_status(
        Format.status(time_remaining, repeat_index, @repeat_total, on_break)
      ) unless @pause_time
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
end
