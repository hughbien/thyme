require "../thyme"

# Handles all things related to PID!
#
# The Thyme timer runs as a daemon process. Stopping/pausing/unpausing are all initiated by a
# secondary process. It sends a signal to the main daemon. In order to do so, it needs the daemon's
# PID which is stored in the PID_FILE.
#
# See Thyme::SignalHandler for the actual message sending. This module only deals with reading/writing
# the daemon's PID.
module Thyme::ProcessHandler
  PID_FILE = "#{ENV["HOME"]}/.thyme-pid"

  extend self

  # Returns the PID of the main daemon process. Should only be used by the secondary
  # processes (eg during stopping/pausing/unpausing).
  def read_pid
    File.read(PID_FILE).strip.to_i
  rescue Errno
    raise Error.new("Cannot read #{PID_FILE}, try re-starting thyme")
  end

  # Writes the current process's PID to the PID_FILE. Must only be used by the main process.
  # Must never be used by secondary processes.
  def write_pid
    File.write(PID_FILE, Process.pid.to_s)
  end

  # Clean up by removing PID_FILE.
  def delete_pid
    File.delete(PID_FILE)
  rescue Errno
    # ignore, file already deleted
  end

  # Returns true if main daemon is running.
  def running?
    File.exists?(PID_FILE) && Process.exists?(read_pid)
  end
end
