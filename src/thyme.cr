require "./thyme/**"

module Thyme
  VERSION = {{ `shards version "#{__DIR__}"`.chomp.stringify }}
end
