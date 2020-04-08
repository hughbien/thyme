require "../thyme"

module Thyme::ProcessHandler
  PID_FILE = "#{ENV["HOME"]}/.thyme-pid"

  extend self

  def read_pid
    File.read(PID_FILE).strip.to_i
  rescue Errno
    raise Error.new("Cannot read #{PID_FILE}, try re-starting thyme")
  end

  def write_pid
    File.write(PID_FILE, Process.pid.to_s)
  end

  def delete_pid
    File.delete(PID_FILE)
  rescue Errno
    # ignore, file already deleted
  end

  def running?
    File.exists?(PID_FILE) && Process.exists?(read_pid)
  end
end
