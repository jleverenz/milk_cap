require 'spec_helper'

module MilkCap::RTM
  describe Task do
    it "created and deleted" do
      taskname = "milk the cow #{Time.now.to_i}"

      t0 = Task.add!(taskname)

      t0.should be_a(Task)
      t0.name.should == taskname

      ts = Task.find

      t1 = ts.find { |t| t.task_id == t0.task_id }
      t1.name.should == taskname
      t1.tags.join('.').should == ''

      ts = Task.find :filter => "status:incomplete"

      t1 = ts.find { |t| t.task_id == t0.task_id }
      t1.name.should == taskname

      t1.delete!

      ts = Task.find :filter => "status:incomplete"

      t1 = ts.find { |t| t.task_id == t0.task_id }
      t1.should be_nil
    end

    it "created and deleted on a specified list, filtered find by list" do
      lists = List.find
      work = lists.find { |e| e.name == 'Work' }

      taskname = "more work #{Time.now.to_i}"

      t0 = Task.add! taskname, :list_id => work.list_id

      tasks = Task.find :list_id => work.list_id, :filer => 'status:incomplete'

      tasks.find { |t| t.task_id == t0.task_id }.should_not be_nil

      t0.complete!

      tasks = Task.find :list_id => work.list_id, :filer => 'status:completed'
      tasks.find { |t| t.task_id == t0.task_id }.should_not be_nil

      t0.delete!
    end

    it "uses smart add by default" do
      taskname = "more work #{Time.now.to_i}"
      smart_add_string = "#{taskname} tomorrow"
      task = Task.add! smart_add_string

      tasks = Task.find

      task_created = tasks.find { |t| t.task_id == task.task_id }
      task_created.due.should_not be_empty
      task_created.name.should == taskname  # 'tomorrow' is stripped as due date
    end

    it "can add tasks with smart add turned off" do
      taskname = "more work #{Time.now.to_i} tomorrow"
      task = Task.add! taskname, :parse => false

      tasks = Task.find

      task_created = tasks.find { |t| t.task_id == task.task_id }
      task_created.due.should be_empty
      task_created.name.should == taskname
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
