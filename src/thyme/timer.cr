require "../thyme"

class Thyme::Timer
  private getter tmux : Tmux
  private getter start_time : Time
  private getter end_time : Time

  @stop : Bool = false
  @pause_time : Time | Nil

  def initialize
    @tmux = Tmux.new
    @start_time = Time.local
    @end_time = @start_time + (25*60).seconds
  end

  def run
    while Time.local < end_time
      if @stop
        tmux.set_status("")
        return
      end

      if @pause_time
        sleep(1)
        next
      end

      tmux.set_status(format(time_remaining))
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

  private def format(span : Time::Span)
    seconds = span.seconds >= 10 ? span.seconds : "0#{span.seconds}"
    "#{span.minutes}:#{seconds}"
  end
end
