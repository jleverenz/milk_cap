require 'spec_helper'

module MilkCap::RTM
  describe List do
    it "find standard 'Inbox' list" do
      lists = List.find
      expect(lists.find { |e| e.name == 'Inbox' }).to_not be_nil
    end

    it "List.find accepts API key and shared secret if not in ENV" do
      key = ENV.delete('RTM_API_KEY')
      secret = ENV.delete('RTM_SHARED_SECRET')

      expect do
        lists = List.find
      end.to raise_error(RuntimeError)

      expect(List.find(:api_key => key, :shared_secret => secret)).to_not be_nil

      ENV['RTM_API_KEY'] = key
      ENV['RTM_SHARED_SECRET'] = secret
    end
  end
end
