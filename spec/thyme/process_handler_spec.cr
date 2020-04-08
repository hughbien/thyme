require "../spec_helper"

describe Thyme::ProcessHandler do
  describe ".read_pid" do
    it "raises error when PID_FILE does not exist" do
      setup_pid
      expect_raises(Thyme::Error, /Cannot read/) do
        Thyme::ProcessHandler.read_pid
      end
    end

    it "returns contents of PID_FILE" do
      num = Random.rand(100)
      setup_pid(num)
      Thyme::ProcessHandler.read_pid.should eq(num)
    end
  end

  describe ".write_pid" do
    it "writes current process to PID_FILE" do
      Thyme::ProcessHandler.write_pid
      File.read(Thyme::ProcessHandler::PID_FILE).should eq(Process.pid.to_s)
    end
  end

  describe ".delete_pid" do
    it "removes PID_FILE" do
      setup_pid(100)
      Thyme::ProcessHandler.delete_pid
      File.exists?(Thyme::ProcessHandler::PID_FILE).should be_false
    end
  end

  describe ".running?" do
    it "returns false if PID_FILE is missing" do
      setup_pid
      Thyme::ProcessHandler.running?.should be_false
    end

    it "returns false if process does not exist" do
      setup_pid(-99999999)
      Thyme::ProcessHandler.running?.should be_false
    end

    it "returns true if process exists" do
      setup_pid(Process.pid)
      Thyme::ProcessHandler.running?.should be_true
    end
  end
end
