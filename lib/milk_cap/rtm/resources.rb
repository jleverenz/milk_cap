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
