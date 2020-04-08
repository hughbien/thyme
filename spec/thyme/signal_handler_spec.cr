require "../spec_helper"

describe Thyme::SignalHandler do
  before_all do
    setup_pid(Process.pid.to_s)
  end

  after_all do
    setup_pid(nil)
    Signal::INT.reset
    Signal::USR1.reset
  end

  describe "stopping" do
    it "traps and sends INT signal" do
      called = false
      Thyme::SignalHandler.on_stop do
        called = true
      end
      Thyme::SignalHandler.send_stop
      sleep(0.01) # TODO: how do I block here until handler is called?
      called.should be_true
    end
  end

  describe "toggling" do
    it "traps and sends INT signal" do
      called = false
      Thyme::SignalHandler.on_toggle do
        called = true
      end
      Thyme::SignalHandler.send_toggle
      sleep(0.01) # TODO: :(
      called.should be_true
    end
  end
end
