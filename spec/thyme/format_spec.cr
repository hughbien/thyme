require "../spec_helper"

describe Thyme::Format do
  config = build_config({
    "timer" => 100,
    "timer_warning" => 10,
    "color_default" => "default",
    "color_warning" => "red",
    "color_break" => "blue"
  })

  describe "#status" do
    it "returns formatted minutes and seconds" do
      Thyme::Format.status(630, "", false, config).should contain("10:30")
      Thyme::Format.status(100, "", false, config).should contain("1:40")
      Thyme::Format.status(65, "", false, config).should contain("1:05")
      Thyme::Format.status(1, "", false, config).should contain("0:01")
    end

    it "returns repeat suffix" do
      Thyme::Format.status(65, " (1/4)", false, config).should contain("1:05 (1/4)")
    end

    it "returns wrapped in color" do
      Thyme::Format.status(65, "", true, config).should contain("fg=blue")
    end
  end

  describe "#repeat_suffix" do
    it "handles single loop case" do
      Thyme::Format.repeat_suffix(1, 1).should eq("")
    end

    it "handles unlimited loops case" do
      Thyme::Format.repeat_suffix(2, 0).should eq(" (2)")
    end

    it "handles specified loop case" do
      Thyme::Format.repeat_suffix(3, 4).should eq(" (3/4)")
    end
  end

  describe "#with_color" do
    it "wraps text with color" do
      Thyme::Format.with_color("Lorem Ipsum", "default").should eq(
        "#[fg=default]Lorem Ipsum#[default]"
      )
    end
  end

  describe "#tmux_color" do
    it "returns break color when on_break" do
      Thyme::Format.tmux_color(100, true, config).should eq("blue")
    end

    it "returns warning color when below warning threshold" do
      Thyme::Format.tmux_color(10, false, config).should eq("red")
      Thyme::Format.tmux_color(9, false, config).should eq("red")
    end

    it "returns default color when not on break or below warning threshold" do
      Thyme::Format.tmux_color(11, false, config).should eq("default")
    end
  end
end
