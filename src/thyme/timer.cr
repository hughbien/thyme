require "../thyme"

class Thyme::Timer
  @tmux : Tmux
  @stop : Bool = false
  @repeat_total : Int32 = 5
  @end_time : Time
  @pause_time : Time | Nil

  def initialize
    @tmux = Tmux.new
    @end_time = Time.local + (25*60).seconds
  end

  def run
    repeat_index = 1
    while @repeat_total == 0 || repeat_index <= @repeat_total
      break if @stop

      run_single(repeat_index)
      run_single(repeat_index, true) unless repeat_index == @repeat_total
      repeat_index += 1
    end
    @tmux.set_status("")
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

  private def run_single(repeat_index, on_break = false)
    return if @stop

    @end_time = Time.local + ((on_break ? 1 : 2) * 5).seconds
    while Time.local < @end_time
      if @stop
        @tmux.set_status("")
        return
      end

      @tmux.set_status(
        Format.status(time_remaining, repeat_index, @repeat_total, on_break)
      ) unless @pause_time
      sleep(1)
    end
  end

  private def time_remaining
    @end_time - Time.local
  end
end
