require "../thyme"

module Thyme::SignalHandler
  extend self

  def on_stop(&block)
    Signal::INT.trap { block.call }
  end

  def send_stop
    Process.kill(Signal::INT, ProcessHandler.read_pid)
  end

  def on_toggle(&block)
    Signal::USR1.trap { block.call }
  end

  def send_toggle
    Process.kill(Signal::USR1, ProcessHandler.read_pid)
  end
end
