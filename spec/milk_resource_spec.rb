require 'spec_helper'

module MilkCap::RTM
  describe MilkResource do
    it "uses the same timeline for multiple calls" do

      MilkCap::RTM.should_receive(:get_timeline).once.and_call_original

      taskname = "milk the cow #{Time.now.to_i}"

      task = Task.add!(taskname)
      task.delete!
    end

  end
end
