require 'spec_helper'

module MilkCap::RTM
  describe Task do
    it "created and deleted" do
      taskname = "milk the cow #{Time.now.to_i}"

      t0 = Task.add!(taskname)

      expect(t0).to be_a(Task)
      expect(t0.name).to eq taskname

      ts = Task.find

      t1 = ts.find { |t| t.task_id == t0.task_id }
      expect(t1.name).to eq taskname
      expect(t1.tags.join('.')).to eq ''

      ts = Task.find :filter => "status:incomplete"

      t1 = ts.find { |t| t.task_id == t0.task_id }
      expect(t1.name).to eq taskname

      t1.delete!

      ts = Task.find :filter => "status:incomplete"

      t1 = ts.find { |t| t.task_id == t0.task_id }
      expect(t1).to be_nil
    end

    it "created and deleted on a specified list, filtered find by list" do
      lists = List.find
      work = lists.find { |e| e.name == 'Work' }

      taskname = "more work #{Time.now.to_i}"

      t0 = Task.add! taskname, :list_id => work.list_id

      tasks = Task.find :list_id => work.list_id, :filer => 'status:incomplete'

      expect(tasks.find { |t| t.task_id == t0.task_id }).to_not be_nil

      t0.complete!

      tasks = Task.find :list_id => work.list_id, :filer => 'status:completed'
      expect(tasks.find { |t| t.task_id == t0.task_id }).to_not be_nil

      t0.delete!
    end

    it "uses smart add by default" do
      taskname = "more work #{Time.now.to_i}"
      smart_add_string = "#{taskname} tomorrow"
      task = Task.add! smart_add_string

      tasks = Task.find

      task_created = tasks.find { |t| t.task_id == task.task_id }
      expect(task_created.due).to_not be_empty
      expect(task_created.name).to eq taskname  # 'tomorrow' is stripped as due date
    end

    it "can add tasks with smart add turned off" do
      taskname = "more work #{Time.now.to_i} tomorrow"
      task = Task.add! taskname, :parse => false

      tasks = Task.find

      task_created = tasks.find { |t| t.task_id == task.task_id }
      expect(task_created.due).to be_empty
      expect(task_created.name).to eq taskname
    end

    # https://github.com/jleverenz/milk_cap/issues/1
    it "parses taskseries with tasks array -- repeating tasks with come completed" do
      taskname = "milk the cow #{Time.now.to_i} *daily"
      task = Task.add!(taskname)
      task.complete!
      ts = Task.find  # this was throwing a TypeError
    end

  end
end
