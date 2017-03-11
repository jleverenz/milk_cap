require 'spec_helper'

module MilkCap::RTM
  describe 'normalize_tags_array' do
    include DataNormalization

    it 'converts nil and empty string to empty array' do
      expect(normalize_tags_array(nil)).to eq []
      expect(normalize_tags_array('')).to eq []
    end

    it 'converts a single string without commas to a one item array' do
      expect(normalize_tags_array('tag1')).to eq ['tag1']
    end

    it 'converts a comma sperated string list to multiple item array' do
      expect(normalize_tags_array('tag1,tag2')).to eq ['tag1', 'tag2']
    end

    it 'passes through array input as the same output' do
      expect(normalize_tags_array([])).to eq []
      expect(normalize_tags_array(['tag1'])).to eq ['tag1']
      expect(normalize_tags_array(['tag1','tag2'])).to eq ['tag1', 'tag2']
    end

    it 'normalizes (trims) leading and trailing spaces in strings and arrays' do
      expect(normalize_tags_array(' tag1')).to eq ['tag1']
      expect(normalize_tags_array('tag1 , tag2')).to eq ['tag1', 'tag2']
      expect(normalize_tags_array([' tag1'])).to eq ['tag1']
      expect(normalize_tags_array(['tag1 ',' tag2'])).to eq ['tag1', 'tag2']
    end
  end

  describe 'normalize_rtm_tags_hash' do
    include DataNormalization
    it 'handles various flavors of tag data from RTM response' do
      # See function under test for RTM response explanation (3 flavors below)
      expect(normalize_rtm_tags_hash( [] )).to eq []
      expect(normalize_rtm_tags_hash( {"tag" => "tag1" } )).to eq ['tag1']
      expect(normalize_rtm_tags_hash( { "tag" => ["tag1", "tag2"] } )).to eq ['tag1','tag2']
    end
  end
end
