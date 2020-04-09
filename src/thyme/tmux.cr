require "../thyme"

enum Thyme::StatusAlign
  Left
  Right

  def alignment
    to_s.downcase
  end
end

# Handles communication with Tmux. Before/after all pomodoros, the status will be init/reset. Every
# second, the timer will call #set_status with the new label (eg "4:25 (3/4)").
class Thyme::Tmux
  STATUS_INTERVAL = "status-interval"
  TMUX_FILE = "#{ENV["HOME"]}/.thyme-tmux"
  TMUX_STATUS_VAL = "'#(cat #{TMUX_FILE})'"

  @config : Config
  @status_key : String
  @original_status_val : String
  @original_interval_val : String

  def initialize(@config)
    @file = File.open(TMUX_FILE, "w")
    @status_key = "status-#{@config.status_align.alignment}"
    @original_status_val = fetch_tmux_val(@status_key)
    @original_interval_val = fetch_tmux_val(STATUS_INTERVAL)
  end

  def init_status
    return unless @config.status_override
    `tmux set-option -g #{@status_key} #{TMUX_STATUS_VAL}`
    `tmux set-option -g #{STATUS_INTERVAL} 1`
  end

  # Originally tried to set the status directly via a system call to tmux set-option,
  # but ran into a consistent FileDescriptor and `END_OF_STACK` exceptions being raised.
  # See <https://github.com/crystal-lang/crystal/issues/3219>
  def set_status(status)
    @file.truncate
    @file.rewind
    @file.print(status)
    @file.flush
  end

  def reset_status
    if @config.status_override
      # Don't wrap value with quotes, Tmux does this automatically when fetching
      `tmux set-option -g #{@status_key} #{@original_status_val}`
      `tmux set-option -g #{STATUS_INTERVAL} #{@original_interval_val}`
    end
  ensure
    delete_tmux_file
  end

  private def fetch_tmux_val(key) : String
    result = `tmux show-options -g #{key}`.strip
    raise Error.new("Unable to fetch tmux option: #{key}") if result =~ /^invalid option/
    result.split(2).fetch(1, "''")
  end

  private def delete_tmux_file
    @file.delete
  end
end
