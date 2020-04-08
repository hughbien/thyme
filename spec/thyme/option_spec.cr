require "../spec_helper"
require "toml"

describe Thyme::Option do
  describe "#initialize" do
    it "sets fields" do
      option = Thyme::Option.new("example", "-f", "--flag", "test", "echo")
      option.name.should eq("example")
      option.flag.should eq("-f")
      option.flag_long.should eq("--flag")
      option.description.should eq("test")
    end
  end

  describe "#call" do
    it "executes command with placeholders filled" do
      file = File.tempfile
      option = Thyme::Option.new(
        "example",
        "-f",
        "--flag",
        "test",
        "echo \"flag=\#{flag} args=\#{args}\" > #{file.path}"
      )
      option.call({ flag: "flag1", args: "arg1 arg2" })

      contents = File.read(file.path)
      contents.should contain("flag=flag1")
      contents.should contain("args=arg1 arg2")
      file.delete
    end
  end

  describe ".parse" do
    it "raises error when field is not a string" do
      expect_raises(Thyme::Error, /invalid/) do
        Thyme::Option.parse("example", TOML.parse("flag = 1"))
      end
    end

    it "raises error when field is missing" do
      expect_raises(Thyme::Error, /missing/) do
        Thyme::Option.parse("example", TOML.parse(""))
      end
    end

    it "returns Thyme::Option from TOML" do
      toml = TOML.parse(
        <<-CONFIG
        flag = "-f"
        flag_long = "--flag"
        description = "Lorem Ipsum"
        command = "echo hello"
        CONFIG
      )
      option = Thyme::Option.parse("example", toml)
      option.name.should eq("example")
      option.flag.should eq("-f")
      option.flag_long.should eq("--flag")
      option.description.should eq("Lorem Ipsum")
    end
  end

  describe ".validate!" do
    toml = TOML.parse("int_value = 1\nstr_value = \"test\"")

    it "raises error when field is not a string" do
      expect_raises(Thyme::Error, /invalid/) do
        Thyme::Option.validate!(toml, "", "int_value")
      end
    end

    it "raises error when field is missing" do
      expect_raises(Thyme::Error, /missing/) do
        Thyme::Option.validate!(toml, "", "missing_value")
      end
    end

    it "returns value for key" do
      Thyme::Option.validate!(toml, "", "str_value").should eq("test")
    end
  end
end
