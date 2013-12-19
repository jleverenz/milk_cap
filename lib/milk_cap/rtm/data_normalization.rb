module MilkCap::RTM

  # Helper methods to normalize incoming data
  module DataNormalization

    # Converts various forms of tag lists into an Array of strings.
    #
    # +tags+ can be nil, a string of one or more comma separated tags, or an
    # array.  Returns an array of stripped strings.
    def normalize_tags_array(tags)
      return [] if tags.nil?

      if tags.kind_of? String
        tags = tags.split(",")
      end
      return tags.map { |i| i.strip }
    end

    # Normalize data values returned in RTM's json 'tags' keys to an Array of strings.
    #
    # RTM returns the value for it's 'tags' key in a few formats:
    #
    # When there are no tags, an empty JSON array: []
    #
    # When there is one tag, a hash with "tag" key, set to a string for the tagname:
    # { "tag": "tagname" }
    #
    # When there are multiple tags, a hash with "tag" key, set to a JSON array of strings:
    # { "tag": ["tagname1", "tagname2"] }
    #
    def normalize_rtm_tags_hash(tags_hash)
      if tags_hash.is_a?(Array)
        tags_hash
      else
        if tags_hash['tag'].is_a?(Array)
          tags_hash['tag']
        else
          [tags_hash['tag']]
        end
      end
    end
  end

end
