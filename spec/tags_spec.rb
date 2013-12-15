require 'spec_helper'

# TODO Test tags dirty flag, ensure it doesn't save when clean

module MilkCap::RTM
  describe 'Task tags' do
    it 'can set a single tag and retrieve it from RTM' do
      taskname = "milk the cow #{Time.now.to_i}"

      task = Task.add!(taskname)
      task.tags.join(',').should == ''
      task.tags = 'tag1'
      task.save!

      tasks = Task.find
      t = tasks.find { |i| i.task_id == task.task_id }
      t.tags.join(",").should == 'tag1'
    end

    it 'can set multiple tags and retrive them from RTM' do
      taskname = "milk the cow #{Time.now.to_i}"

      task = Task.add!(taskname)
      task.tags.join(',').should == ''
      task.tags = 'tag1,tag2'
      task.save!

      tasks = Task.find
      t = tasks.find { |i| i.task_id == task.task_id }

      # TODO clean this up once TagArray is refactored
      collect = []
      t.tags.each { |i| collect << i }
      collect.sort.join(",").should == "tag1,tag2"
    end
  end
end
