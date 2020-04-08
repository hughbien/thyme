require "spec"
require "../src/thyme"

def build_config(values = Hash(String, String | UInt32 | Bool).new)
  file = File.tempfile
  values.each do |key, value|
    value = "\"#{value}\"" if value.as?(String)
    file << "#{key} = #{value}\n"
  end
  file.close
  Thyme::Config.parse(file.path)
ensure
  file.delete if file
end
