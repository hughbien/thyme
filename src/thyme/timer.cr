require "../thyme"

class Thyme::Timer
  private getter tmux : Tmux
  private getter start_time : Time
  private getter end_time : Time

  def initialize
    @tmux = Tmux.new
    @start_time = Time.local
    @end_time = @start_time + (25*60).seconds
  end

  def run
    while Time.local < end_time
      tmux.set_status(format(time_remaining))
      sleep(1)
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
