require "../spec_helper"
require "yaml"
require "uuid"

describe Thyme::Hook do
  describe "#initialize" do
    it "sets fields" do
      events = [Thyme::HookEvent::Before, Thyme::HookEvent::AfterAll]
      hook = Thyme::Hook.new("name", events, "echo")
      hook.name.should eq("name")
      hook.events.should eq(events)
    end
  end

  describe "#call" do
    it "runs command with placeholders filled" do
      uuid = UUID.random
      file = File.tempfile
      hook = build_hook(
        "before",
        "echo '#{uuid} \#{repeat_index} \#{repeat_total} \#{repeat_suffix}' > #{file.path}"
      )
      hook.call(hooks_args)
      File.read(file.path).should eq("#{uuid} 1 2 (1/2)\n")
      file.delete
    end
  end

  describe ".parse" do
    it "raises error on missing events" do
      yaml = YAML.parse("command: \"\"")
      expect_raises(Thyme::Error, /missing `events`/) do
        Thyme::Hook.parse("name", yaml)
      end
    end

    it "raises error on invalid event" do
      yaml = YAML.parse("events: 1\ncommand: \"\"")
      expect_raises(Thyme::Error, /invalid `events`/) do
        Thyme::Hook.parse("name", yaml)
      end
    end

    it "raises error on unknown event" do
      yaml = YAML.parse("events: \"not-an-event\"\ncommand: \"\"")
      expect_raises(Thyme::Error, /invalid `events`/) do
        Thyme::Hook.parse("name", yaml)
      end
    end

    it "raises error on missing command" do
      yaml = YAML.parse("events: \"before\"")
      expect_raises(Thyme::Error, /missing `command`/) do
        Thyme::Hook.parse("name", yaml)
      end
    end

    it "raises error on invalid command" do
      yaml = YAML.parse("events: \"before\"\ncommand: 1")
      expect_raises(Thyme::Error, /invalid `command`/) do
        Thyme::Hook.parse("name", yaml)
      end
    end

    it "returns a Hook" do
      yaml = YAML.parse("events: \"before\"\ncommand: \"\"")
      hook = Thyme::Hook.parse("name", yaml)
      hook.name.should eq("name")
      hook.events.should eq([Thyme::HookEvent::Before])
    end
  end
end
