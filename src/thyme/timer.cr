require "../thyme"

class Thyme::Timer
  @config : Config
  @tmux : Tmux
  @stop : Bool = false
  @end_time : Time
  @pause_time : Time | Nil

  def initialize(@config)
    @tmux = Tmux.for(@config)
    @end_time = Time.local + @config.timer.seconds
  end

  def run
    repeat_index = 1
    while @config.repeat == 0 || repeat_index <= @config.repeat
      break if @stop

      run_single(repeat_index)
      run_single(repeat_index, true) unless repeat_index == @config.repeat
      repeat_index += 1
    end
    @tmux.reset_status
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

    repeat_suffix = Format.repeat_suffix(repeat_index, @config.repeat)
    hooks_args = {
      repeat_index: repeat_index,
      repeat_total: @config.repeat,
      repeat_suffix: repeat_suffix.strip
    }
    @config.hooks.before_all(hooks_args) if repeat_index == 1 && !on_break
    on_break ? @config.hooks.before_break(hooks_args) : @config.hooks.before(hooks_args)

    @end_time = Time.local + (on_break ? @config.timer_break : @config.timer).seconds
    while Time.local < @end_time
      if @stop
        @tmux.reset_status
        return
      end

      @tmux.set_status(
        Format.status(time_remaining, repeat_suffix, on_break, @config)
      ) unless @pause_time
      sleep(1)
    end

    on_break ? @config.hooks.after_break(hooks_args) : @config.hooks.after(hooks_args)
    @config.hooks.after_all(hooks_args) if repeat_index == @config.repeat && !on_break
  end

  private def time_remaining
    @end_time - Time.local
  end
end
