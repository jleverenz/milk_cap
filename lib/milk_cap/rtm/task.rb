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

require 'milk_cap/rtm/resources'

module MilkCap::RTM
  #
  # The RTM Task class.
  #
  class Task < MilkResource
    include DataNormalization

    def self.task_attr (*att_names) #:nodoc:

      att_names.each do |att_name|
        class_eval %{
          def #{att_name}
            @task_hash['#{att_name}']
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

    # Task series may have multiple tasks. task_hash used to specify which task
    # in series.
    def initialize (list_id, task_series_hash, task_hash)

      super(task_series_hash)
      @task_hash = task_hash

      @list_id = list_id
      @taskseries_id = task_series_hash['id']
      @task_id = @task_hash['id']

      # Normalize the RTM structure and put it in TagArray
      tags = normalize_rtm_tags_hash( task_series_hash['tags'] )
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

      # o is an array of taskseries.  Collect flattened array of tasks out of
      # all taskseries
      o.inject([]) do |m,s|
        tasks = s['task']
        tasks = [ tasks ] unless tasks.is_a?(Array)
        m + tasks.collect { |t| self.new(list_id, s, t) }
      end
    end
  end
end
