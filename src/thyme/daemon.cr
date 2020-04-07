lib LibC
  fun setsid : PidT
end

module Daemon
  def self.start!(
    stdin = "/dev/null",
    stdout = "/dev/null",
    stderr = "/dev/null",
    dir = "/"
  )
    exit if fork
    LibC.setsid
    exit if fork
    Dir.cd(dir)

    STDIN.reopen(File.open(stdin, "a+"))
    STDOUT.reopen(File.open(stdout, "a"))
    STDERR.reopen(File.open(stderr, "a"))
  end
end
