#--
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#
# Made in Japan.
#++


module MilkCap::RTM

  #
  # A parent class for Task, List and co.
  #
  # Never use directly.
  #
  class MilkResource

    def initialize (hsh)

      @hsh = hsh
    end

    protected

    # a class method for listing attributes that can be found
    # in the hash reply coming from RTM...
    #
    def self.milk_attr (*att_names) #:nodoc:

      att_names.each do |att_name|
        class_eval %{
          def #{att_name}
            @hsh['#{att_name}']
          end
        }
      end
    end

    # Calls the milk() method (interacts with the RTM API).
    #
    def self.execute (method_name, args={})

      args[:method] = "rtm.#{resource_name}.#{method_name}"

      MilkCap::RTM.milk(args)
    end

    # Returns the name of the resource as the API knows it
    # (for example 'tasks' or 'lists').
    #
    def self.resource_name

      self.to_s.split('::')[-1].downcase + 's'
    end

    # Simply calls the timeline() class method.
    #
    def timeline

      MilkResource.timeline
    end

    # Returns the current timeline (fetches one if none has yet
    # been prepared).
    #
    def self.timeline

      @@timeline ||= MilkCap::RTM.get_timeline
    end
  end

  #
  # The RTM Task class.
  #
  class Task < MilkResource
    include DataNormalization

    def self.task_attr (*att_names) #:nodoc:

      att_names.each do |att_name|
        class_eval %{
          def #{att_name}
            @hsh['task']['#{att_name}']
          end
        }
      end
    end

    attr_reader \
      :list_id,
      :taskseries_id,
      :task_id,
      :tags

    milk_attr \
      :name,
      :modified,
      :participants,
      :url,
      :notes,
      :location_id,
      :created,
      :source

    task_attr \
      :completed,
      :added,
      :postponed,
      :priority,
      :deleted,
      :has_due_time,
      :estimate,
      :due

    def initialize (list_id, h)

      super(h)

      t = h['task']

      @list_id = list_id
      @taskseries_id = h['id']
      @task_id = t['id']

      # Normalize the RTM structure and put it in TagArray
      tags = normalize_rtm_tags_hash( h['tags'] )
      @tags = TagArray.new(self, tags)
    end

    def save!
      if self.tags.dirty?
        args = prepare_api_args.merge( tags: self.tags.join(",") )
        self.class.execute('setTags', args)
      end
    end

    # Deletes the task.
    #
    def delete!

      self.class.execute('delete', prepare_api_args)
    end

    # Marks the task as completed.
    #
    def complete!

      self.class.execute('complete', prepare_api_args)
    end

    # Sets the tags for the task.
    #
    def tags= (tags)
      @tags = TagArray.new(self, normalize_tags_array(tags))
      @tags.dirty!
    end

    def self.find (params={})

      parse_tasks(execute('getList', params))
    end

    # Adds a new task (and returns it).
    #
    def self.add! (name, opts = {})
      opts = { list_id: nil, parse: true }.merge(opts)

      args = {}
      args[:name] = name
      args[:list_id] = opts[:list_id] if opts[:list_id]
      args[:timeline] = timeline
      args[:parse] = 1 unless !opts[:parse]

      h = execute('add', args)

      parse_tasks(h)[0]
    end

    protected

    def prepare_api_args
      {
        :timeline => timeline,
        :list_id => list_id,
        :taskseries_id => taskseries_id,
        :task_id => task_id
      }
    end

    def self.parse_tasks (o)

      o = if o.is_a?(Hash)

        r = o[resource_name]
        o = r if r
        o['list']
      end

      o = [ o ] unless o.is_a?(Array)
        # Nota bene : not the same thing as  o = Array(o)

      o.inject([]) do |r, h|

        list_id = h['id']
        s = h['taskseries']
        r += parse_taskseries(list_id, s) if s
        r
      end
    end

    def self.parse_taskseries (list_id, o)

      o = [ o ] unless o.is_a?(Array)
      o.collect { |s| self.new(list_id, s) }
    end
  end

  class List < MilkResource

    attr \
      :list_id

    milk_attr \
      :name, :sort_order, :smart, :archived, :deleted, :position, :locked

    def initialize (h)

      super
      @list_id = h['id']
    end

    def self.find (params={})

      execute('getList', params)[resource_name]['list'].collect do |h|
        self.new(h)
      end
    end
  end

  #
  # An array of tasks.
  #
  class TagArray #:nodoc:
    include Enumerable

    # TODO introduce method to return state change between clean & dirty tags
    # in order to use addTags or removeTags instead of just setTags.

    def initialize (task, tags)
      @dirty = false
      @prev = @tags = tags
    end

    def dirty=(dirty_state)
      @dirty = dirty_state
      @prev = @tags if !dirty_state
    end
    def dirty!; self.dirty=true; end
    def dirty?; @dirty; end

    def << (tag)
      @tags << tag
      self.dirty!
    end

    def delete (tag)
      @tags.delete tag
      self.dirty!
    end

    def clear

      @tags.clear
      self.dirty!
    end

    def join (s)
      @tags.join(s)
    end

    def each
      @tags.each { |e| yield e }
    end
  end

end
