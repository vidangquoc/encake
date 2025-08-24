#encoding: utf-8
require 'spec_helper'

RSpec.describe Network::WordMeaning do
  
  describe "fetch_for" do
    
    it "fetchs the right meanings" do
      
      result = Network::WordMeaning.fetch_for("love")
      
      expect(result.any?{|item| item[:type_name] == "danh từ" and item[:meaning] =~ /tình yêu/}).to be true
      expect(result.any?{|item| item[:type_name] == "ngoại động từ" and item[:meaning] =~ /yêu/}).to be true
      
      expect(result.count).to be 8
      
    end
    
    it "ignores the meanings if the page title does not match the searched word" do
      
      result = Network::WordMeaning.fetch_for("called")
      
      expect(result.count).to be 0
      
    end
    
  end
  
end