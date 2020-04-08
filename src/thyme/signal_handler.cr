require "../thyme"

# Thyme runs in multiple processes (sort of):
# 1. the main daemon process - where the timer runs continuously
# 2. secondary processes - which start to send stop/pause/unpause to the main process
#
# SignalHandler is used for sending/receiving messages. Receiving should only be done
# on the main process. Sending should only be done on the secondary process.
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
