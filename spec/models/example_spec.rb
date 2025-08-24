require 'spec_helper'

describe Example do
  
  before :each do
    allow(Network::TextToSpeech).to receive(:word_to_speech).and_return(nil)
    allow(Network::TextToSpeech).to receive(:phase_to_speech).and_return(nil)
    allow(Network::WordPronunciation).to receive(:fetch_for).and_return({possible_pronunciations: [], valid_pronunciation: nil});
  end
  
  describe 'validations' do
    
    subject do
      FactoryBot.create(:example)
    end      
    
    it { is_expected.to validate_presence_of(:content) }
    
    it { is_expected.to validate_presence_of(:meaning) }
    
    it { is_expected.to validate_presence_of(:point_id) }      
        
  end
  
  describe 'methods' do
    
    describe 'find_sound' do
      
      before :each do
        @example = Example.one
        @point = Point.one
        @example.belongs_to @point
      end
             
      it 'creates corresponding sound if none exists' do
        @example.find_sound
        expect(@example.sound).not_to be nil
        expect(@example.sound.for_content).to eq(@example.content)
      end
      
      it 'does not create corresponding sound if parent point is private' do
        @point.update_attribute :is_private, true
        @example.find_sound
        expect(@example.sound).to be nil
      end
      
      it 'connects to corresponding sound if one exists' do
        sound = Sound.create!(:for_content => @example.content)
        @example.find_sound
        expect(@example.sound.id).to be sound.id
      end
      
    end
    
    describe 'is_main' do
      
      before :each do
        @point = Point.one
        @main_example, @none_main_example = @point.has_2_examples(:assoc)        
        @point.main_example = @main_example
        @point.save
      end
      
      it 'returns true if the answer is the right answer of the parent point' do       
        expect(@main_example.is_main).to be true
      end
      
      it 'returns false if the answer is not the right answer of the parent point' do        
        expect(@none_main_example.is_main).to be false
      end
      
    end        
    
    describe 'is_main=' do
          
      before :each do
        @point = Point.one.has_2_examples
        @example = FactoryBot.build :example
        @example.point = @point
      end
      
      it 'makes the example to be the main example of parent point if the passed-in argument is true' do
                 
        @example.is_main = true
        @example.save
        
        expect(@point.reload.main_example_id).to be @example.id
        
      end
      
      it 'does not makes the example to be the main example of parent point if the passed-in argument is false' do
               
        @example.is_main = false
        @example.save
        
        expect(@point.reload.main_example_id).not_to be @example.id
        
      end
      
      it 'does not turn the main example to become a none-main example if the passed-in argument is false' do
        
        @example.is_main = true
        @example.save
        expect(@point.reload.main_example_id).to be @example.id
        
        @example.is_main = false
        @example.save
        expect(@point.reload.main_example_id).to be @example.id
        
      end
  
    end
    
  end
  
  describe 'callbacks' do
            
    before :each do      
      @point = Point.one
    end
    
    context 'after creating' do
           
      context 'first example' do
        
        it 'becomes the main example of the parent point' do
          
          @example = FactoryBot.build :example                   
          @example.point = @point                
          @example.save                   
          expect(@point.reload.main_example.id).to be @example.id
                    
        end
        
      end
      
      it 'updates parent point' do
        
        @example = FactoryBot.build :example                   
        @example.point = @point
        @point.update_attribute :updated_at, today - 1.day
        @example.save
        
        expect(@point.reload.updated_at.localtime.to_date).to eq today
        
      end
            
    end
        
    context 'after updating' do
      
      before :each do
        @example = Example.one
      end
      
      it 'updates parent point' do
        
        @example.update_attribute :point, @point
        @point.update_attribute :updated_at, today - 1.day
        @example.save
        
        expect(@point.reload.updated_at.localtime.to_date).to eq Date.today
        
      end
                                    
      context 'content changes' do
                
        context 'main example' do
                  
          it 'triggers the example to find sound' do
            
            @point.update_attribute :main_example_id, @example.id
            @example.update_attribute :point, @point
            
            expect_any_instance_of(Example).to receive(:find_sound)
            @example.content = 'new content'
            @example.save
            
          end
                         
        end
        
        context 'not a main example' do                  
                   
          it 'does not trigger the example to find sound' do
            
            expect_any_instance_of(Example).not_to receive(:find_sound)
            @example.content = 'new content'
            @example.save
            
          end
                         
        end
      
      end            
      
      context 'content unchanges' do
        
         it 'does not trigger the example to find sound' do
           
          @point.update_attribute :main_example_id, @example.id
          @example.update_attribute :point, @point
          
          expect_any_instance_of(Example).not_to receive(:find_sound)
          @example.meaning = 'new meaning'
          @example.save
          
        end
                 
      end
      
    end
    
    context 'after destroy' do
      
      it "tells parent point to update it's validity" do
        point = Point.one
        example1, example2 = point.has_2_examples(:assoc)
        expect_any_instance_of(Point).to receive(:update_validity)
        example1.destroy        
      end
      
      it "touch parent point" do
        
        example = Example.one       
        example.update_attribute :point, @point
        @point.update_attribute :updated_at, today - 10.day
        example.destroy
        
        expect(@point.reload.updated_at.localtime.to_date).to eq Date.today
        
      end
      
    end
        
  end
  
end
