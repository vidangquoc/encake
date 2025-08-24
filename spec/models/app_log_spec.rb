require_relative '../spec_helper'

describe AppLog do
  
  describe 'methods' do
    
    describe 'Class#log' do
      
      it 'creates a log' do
        
        AppLog.log("The content", 'a type', 'a device')
        
        expect(AppLog.count).to be 1
        
      end
        
    end
    
  end
  
end
