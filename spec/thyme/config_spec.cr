require "../spec_helper"
require "yaml"

describe Thyme::Config do
  describe "#initialize" do
    it "raises error on invalid integer" do
      expect_raises(Thyme::Error, /Invalid value for `timer`/) do
        Thyme::Config.new(YAML.parse("timer: \"1\""))
      end
    end

    it "raises error on invalid unsigned integer" do
      expect_raises(Thyme::Error, /Invalid value for `timer`/) do
        Thyme::Config.new(YAML.parse("timer: -1"))
      end
    end

    it "raises error on invalid string" do
      expect_raises(Thyme::Error, /Invalid value for `color_default`/) do
        Thyme::Config.new(YAML.parse("color_default: 1"))
      end
    end

    it "raises error on invalid boolean" do
      expect_raises(Thyme::Error, /Invalid value for `status_override`/) do
        Thyme::Config.new(YAML.parse("status_override: 1"))
      end
    end

    it "raises error on invalid alignment" do
      expect_raises(Thyme::Error, /Invalid value for `status_align`/) do
        Thyme::Config.new(YAML.parse("status_align: \"invalid-align\""))
      end
    end

    it "sets configuration defaults" do
      config = Thyme::Config.new(YAML.parse(""))
      config.timer.should eq(1500)
      config.timer_break.should eq(300)
      config.timer_warning.should eq(300)
      config.repeat.should eq(1)

      config.color_default.should eq("default")
      config.color_warning.should eq("red")
      config.color_break.should eq("default")

      config.status_align.should eq(Thyme::StatusAlign::Right)
      config.status_override.should be_true

      config.hooks.size.should eq(0)
      config.options.size.should eq(0)
    end

    it "sets configuration values" do
      yaml = <<-CONFIG
      timer: 3
      timer_break: 2
      timer_warning: 1
      repeat: 4

      color_default: "red"
      color_warning: "green"
      color_break: "blue"

      status_align: "left"
      status_override: false

      hooks:
        notify:
          events: "after"
          command: "echo"

      options:
        hello:
          flag: "-h"
          flag_long: "--hello"
          description: "say hello"
          command: "echo"
      CONFIG

      config = Thyme::Config.new(YAML.parse(yaml))
      config.timer.should eq(3)
      config.timer_break.should eq(2)
      config.timer_warning.should eq(1)
      config.repeat.should eq(1) # thymerc value is only used with `-r` flag

      config.color_default.should eq("red")
      config.color_warning.should eq("green")
      config.color_break.should eq("blue")

      config.status_align.should eq(Thyme::StatusAlign::Left)
      config.status_override.should be_false

      config.hooks.size.should eq(1)
      config.options.size.should eq(1)

      option = config.options[0]
      option.flag.should eq("-h")
      option.flag_long.should eq("--hello")
      option.description.should eq("say hello")
    end
  end

  describe "#set_repeat" do
    it "sets to repeat count from flag" do
      config = Thyme::Config.new(YAML.parse(""))
      config.set_repeat("33")
      config.repeat.should eq(33)
    end

    it "sets to repeat count from config" do
      config = Thyme::Config.new(YAML.parse("repeat: 32"))
      config.set_repeat
      config.repeat.should eq(32)
    end

    it "sets repeat count to zero as last resort" do
      config = Thyme::Config.new(YAML.parse(""))
      config.set_repeat
      config.repeat.should eq(0)
    end

    it "raises error on invalid repeat count" do
      config = Thyme::Config.new(YAML.parse(""))
      expect_raises(Thyme::Error, /Invalid value for `repeat`/) do
        config.set_repeat("invalid-repeat")
      end
    end
  end

  describe ".parse" do
    file = File.tempfile
    
    before_each do
      File.write(file.path, "")
    end

    after_all do
      file.delete
    end

    it "raises error on invalid YAML" do
      File.write(file.path, "=\"\n")
      expect_raises(Thyme::Error, /Unable to parse/) do
        Thyme::Config.parse(file.path)
      end
    end

    it "handles non existing file" do
      config = Thyme::Config.parse(file.path)
      config.should be_a(Thyme::Config)
    end

    it "returns Config on valid YAML" do
      File.write(file.path, "one: 2")
      config = Thyme::Config.parse(file.path)
      config.should be_a(Thyme::Config)
    end
  end
end
