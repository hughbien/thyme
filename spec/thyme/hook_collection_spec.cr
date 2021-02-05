require "../spec_helper"
require "yaml"

describe Thyme::HookCollection do
  file = File.tempfile
  hooks = Thyme::HookCollection.new([
    "before", "before_break", "before_all",
    "after", "after_break", "after_all"
  ].map { |event| build_hook(
      event, "echo '#{event} \#{repeat_index} \#{repeat_total} \#{repeat_suffix}' >> #{file.path}"
    )
  })

  before_each do
    File.write(file.path, "")
  end

  after_all do
    file.delete
  end

  describe "#size" do
    it "delegates to hooks" do
      hooks.size.should eq(6)
    end
  end

  describe "#before" do
    it "runs before hooks" do
      hooks.before(hooks_args)
      File.read(file.path).should eq("before 1 2 (1/2)\n")
    end
  end

  describe "#before_break" do
    it "runs before_break hooks" do
      hooks.before_break(hooks_args)
      File.read(file.path).should eq("before_break 1 2 (1/2)\n")
    end
  end

  describe "#before_all" do
    it "runs before_all hooks" do
      hooks.before_all(hooks_args)
      File.read(file.path).should eq("before_all 1 2 (1/2)\n")
    end
  end

  describe "#after" do
    it "runs after hooks" do
      hooks.after(hooks_args)
      File.read(file.path).should eq("after 1 2 (1/2)\n")
    end
  end

  describe "#after_break" do
    it "runs after_break hooks" do
      hooks.after_break(hooks_args)
      File.read(file.path).should eq("after_break 1 2 (1/2)\n")
    end
  end

  describe "#after_all" do
    it "runs after_all hooks" do
      hooks.after_all(hooks_args)
      File.read(file.path).should eq("after_all 1 2 (1/2)\n")
    end
  end

  describe ".parse" do
    it "raises error when hooks is invalid" do
      yaml = YAML.parse("hooks: 1\n")
      expect_raises(Thyme::Error, /Invalid value for `hooks`/) do
        Thyme::HookCollection.parse(yaml["hooks"])
      end
    end

    it "returns collection on success" do
      yaml = YAML.parse("hooks:\n  notify:\n    events: \"before\"\n    command: \"echo\"")
      collection = Thyme::HookCollection.parse(yaml["hooks"])
      collection.is_a?(Thyme::HookCollection).should be_true
    end
  end
end
