require 'spec_helper'

# TODO Test tags dirty flag, ensure it doesn't save when clean

module MilkCap::RTM
  describe 'Task tags' do
    it 'can set a single tag and retrieve it from RTM' do
      taskname = "milk the cow #{Time.now.to_i}"

      task = Task.add!(taskname)
      expect(task.tags.join(',')).to eq ''
      task.tags = 'tag1'
      task.save!

      tasks = Task.find
      t = tasks.find { |i| i.task_id == task.task_id }
      expect(t.tags.join(",")).to eq 'tag1'
    end

    it 'can set multiple tags with CSV and retrive them from RTM' do
      taskname = "milk the cow #{Time.now.to_i}"

      task = Task.add!(taskname)
      expect(task.tags.join(',')).to eq ''
      task.tags = 'tag1,tag2'
      task.save!

      tasks = Task.find
      t = tasks.find { |i| i.task_id == task.task_id }

      # TODO clean this up once TagArray is refactored
      collect = []
      t.tags.each { |i| collect << i }
      expect(collect.sort.join(",")).to eq "tag1,tag2"
    end

    it 'can set multiple tags with array and retrive them from RTM' do
      taskname = "milk the cow #{Time.now.to_i}"

      task = Task.add!(taskname)
      expect(task.tags.to_a.join(',')).to eq ''
      task.tags = ['tag1','tag2']
      task.save!

      tasks = Task.find
      t = tasks.find { |i| i.task_id == task.task_id }

      expect(t.tags.to_a.sort.join(",")).to eq "tag1,tag2"
    end

    it 'can add a tag, preserving current tags' do
      taskname = "milk the cow #{Time.now.to_i}"

      task = Task.add!(taskname)
      expect(task.tags.join(',')).to eq ''
      task.tags = 'tag1,tag2'
      task.save!

      # find the same task again
      task = Task.find.find { |i| i.name == taskname }
      task.tags << 'tag3'
      task.save!

      task = Task.find.find { |i| i.name == taskname }
      collect = []
      task.tags.each { |i| collect << i }
      expect(collect.sort.join(",")).to eq 'tag1,tag2,tag3'
    end

    it 'can remove a single tag' do
      taskname = "milk the cow #{Time.now.to_i}"

      task = Task.add!(taskname)
      expect(task.tags.join(',')).to eq ''
      task.tags = 'tag1,tag2'
      task.save!

      # find the same task again
      task = Task.find.find { |i| i.name == taskname }
      task.tags.delete 'tag2'
      task.save!

      task = Task.find.find { |i| i.name == taskname }
      collect = []
      expect(task.tags.join(",")).to eq 'tag1'
    end
  end
end
