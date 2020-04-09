require "./spec_helper"

describe Thyme do
  it "sets VERSION" do
    Thyme::VERSION.should_not be_nil
  end

  it "sets Error" do
    Thyme::Error.should be < Exception
  end
end
