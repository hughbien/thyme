lib LibC
  fun setsid : PidT
end

module Thyme::Daemon
  DEV_NULL = "/dev/null"
  ROOT_DIR = "/"

  # Daemonizes the current process. TODO: add logging for development.
  def self.start!
    exit if fork
    LibC.setsid
    exit if fork
    Dir.cd(ROOT_DIR)

    STDIN.reopen(File.open(DEV_NULL, "a+"))
    STDOUT.reopen(File.open(DEV_NULL, "a"))
    STDERR.reopen(File.open(DEV_NULL, "a"))
  end
end
