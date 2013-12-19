require 'spec_helper'

module MilkCap::RTM
  describe 'normalize_tags_array' do
    include DataNormalization

    it 'converts nil and empty string to empty array' do
      normalize_tags_array(nil).should == []
      normalize_tags_array('').should == []
    end

    it 'converts a single string without commas to a one item array' do
      normalize_tags_array('tag1').should == ['tag1']
    end

    it 'converts a comma sperated string list to multiple item array' do
      normalize_tags_array('tag1,tag2').should == ['tag1', 'tag2']
    end

    it 'passes through array input as the same output' do
      normalize_tags_array([]).should == []
      normalize_tags_array(['tag1']).should == ['tag1']
      normalize_tags_array(['tag1','tag2']).should == ['tag1', 'tag2']
    end

    it 'normalizes (trims) leading and trailing spaces in strings and arrays' do
      normalize_tags_array(' tag1').should == ['tag1']
      normalize_tags_array('tag1 , tag2').should == ['tag1', 'tag2']
      normalize_tags_array([' tag1']).should == ['tag1']
      normalize_tags_array(['tag1 ',' tag2']).should == ['tag1', 'tag2']
    end
  end

  describe 'normalize_rtm_tags_hash' do
    include DataNormalization
    it 'handles various flavors of tag data from RTM response' do
      # See function under test for RTM response explanation (3 flavors below)
      normalize_rtm_tags_hash( [] ).should == []
      normalize_rtm_tags_hash( {"tag" => "tag1" } ).should == ['tag1']
      normalize_rtm_tags_hash( { "tag" => ["tag1", "tag2"] } ).should == ['tag1','tag2']
    end
  end
end
