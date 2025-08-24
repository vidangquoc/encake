require 'spec_helper'

describe Api::V1000::OpportunitiesController do
  
  before :each do
    sign_in User.one
  end
  
  describe "PUT ignore" do
    
    it "sets 'is_taken' attribute to true" do
      
      opportunity = FactoryBot.create :opportunity, is_taken: true
      
      put :ignore, opportunity_id: opportunity.id
      
      should respond_with 200
      
      expect(opportunity.reload.is_taken).to be true
      
    end
    
  end
  
  describe "PUT take" do
    
    before :each do
      @opportunity = FactoryBot.create :opportunity
    end
    
    it "calls Opportunity#take" do
      
      number_of_used_lucky_stars = 10
      
      expect_any_instance_of(Opportunity).to receive(:take).and_return(true)
      
      put :take, opportunity_id: @opportunity.id, number_of_used_lucky_stars: number_of_used_lucky_stars
      
      should respond_with 200
      
    end
    
    it "returns true from Opportunity#take method" do
      
      number_of_used_lucky_stars = 10
      
      allow_any_instance_of(Opportunity).to receive(:take).and_return(true)
      
      put :take, opportunity_id: @opportunity.id, number_of_used_lucky_stars: number_of_used_lucky_stars
      
      expect(json_response.is_won).to be true
      
    end
    
    it "returns true from Opportunity#take method" do
      
      number_of_used_lucky_stars = 10
      
      allow_any_instance_of(Opportunity).to receive(:take).and_return(false)
      
      put :take, opportunity_id: @opportunity.id, number_of_used_lucky_stars: number_of_used_lucky_stars
      
      expect(json_response.is_won).to be false
      
    end
    
  end
  
end