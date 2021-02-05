require "spec"
require "../src/thyme"

def setup_pid(pid = nil)
  if pid
    File.write(Thyme::ProcessHandler::PID_FILE, pid.not_nil!)
  elsif File.exists?(Thyme::ProcessHandler::PID_FILE)
    File.delete(Thyme::ProcessHandler::PID_FILE) 
  end
end

def build_config(values = Hash(String, String | UInt32 | Bool).new)
  file = File.tempfile
  values.each do |key, value|
    value = "\"#{value}\"" if value.as?(String)
    file << "#{key}: #{value}\n"
  end
  file.close
  Thyme::Config.parse(file.path)
ensure
  file.delete if file
end

def build_hook(event = "before", command = "")
  Thyme::Hook.new(event, [Thyme::HookEvent.parse(event)], command)
end

def hooks_args
  {
    repeat_index: "1",
    repeat_total: "2",
    repeat_suffix: "(1/2)"
  }
end
