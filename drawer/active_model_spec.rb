require 'spec_helper'
require Rails.root.join 'lib', 'extensions', 'active_model.rb'

describe ActiveModel::Errors do
  
  before :each do         
    @errors = ActiveModel::Errors.new(User.new)
    @errors.add :email, :presence, :message => 'must be present'
    @errors.add :email, :valid, :message => 'require a valid email'
    @errors.add :first_name, :notblank, :message =>'should not blank'
    @errors.add :first_name, :nospace, :message =>'not contain space'
  end
  
  describe 'add method' do
         
    it 'should save error type' do      
      expect(@errors.error_types).to eq({:email => [:presence, :valid], :first_name => [:notblank, :nospace]})
    end
                
  end
  
  describe 'clear method' do
    
    it 'should clear types' do
      @errors.clear
      expect(@errors.error_types).to be_empty
    end
    
  end
  
  describe 'to_hash_with_types method' do
    
    it 'should return a hash with error type as key' do
      expected = {}
      expected[:email] = {:presence => 'must be present', :valid => 'require a valid email'}
      expected[:first_name] = {:notblank => 'should not blank', :nospace => 'not contain space'} 
      expect(@errors.to_hash_with_types).to eq expected         
    end
    
    it 'should return an empty hash if no error exists' do
      @errors.clear
      expect(@errors.to_hash_with_types).to eq({})
    end
    
  end
  
  describe 'first_error method' do
        
    it 'should return the first error according to orders of searched attributes' do      
      expect(@errors.first_error([:email, :first_name])).to eq ActiveModel::ErrorMessage.new(:email, :presence, 'must be present')           
      expect(@errors.first_error([:first_name, :email])).to eq ActiveModel::ErrorMessage.new(:first_name, :notblank, 'should not blank')
    end
    
    it 'should return nil if no error exists for searched attributes ' do
      expect(@errors.first_error([:middle_name, :last_name])).to be_nil      
    end
    
    it 'should return the first error if searched attributes are not provided' do
      expect(@errors.first_error).to eq ActiveModel::ErrorMessage.new(:email, :presence, 'must be present') 
    end
    
    it 'should return nil if no error exists' do
      @errors.clear
      expect(@errors.first_error).to be_nil      
    end
       
  end
   
end

 
describe ActiveModel::ErrorMessage do
  
  describe '== method' do
    
    it 'should return true if two objects have the same attribute, type, and message' do
      message = ActiveModel::ErrorMessage.new :email, :presence, 'not blank'
      expect(message).to eq ActiveModel::ErrorMessage.new(:email, :presence, 'not blank')
    end
  
  end

end