require 'spec_helper'

describe Sound do
  
  before :each do
        
    word_sound = File.open(Rails.root.join('spec','factories','sample_sounds','admiration.mp3'), 'rb'){ |io| io.read }
    phase_sound = File.open(Rails.root.join('spec','factories','sample_sounds','i_love_you.mp3'), 'rb'){ |io| io.read }
    
    allow(Network::TextToSpeech).to receive(:word_to_speech).and_return(word_sound)
    allow(Network::TextToSpeech).to receive(:phase_to_speech).and_return(phase_sound)
    
    allow(Network::WordPronunciation).to receive(:fetch_for).and_return({
                                                                          possible_pronunciations: ["proʊ", "pro 2"],
                                                                          valid_pronunciations: ["proʊ"]
                                                                        })
    
  end
  
  describe 'validations' do      
    
    it{ is_expected.to validate_presence_of :for_content }
    
    it{ should validate_uniqueness_of :for_content }
    
  end
  
  describe 'methods' do
    
    describe 'fetch_data' do
      
      it 'updates fetched times' do
                                      
        sound = Sound.create(:for_content => 'word')
        expect{sound.fetch_data}.to change(sound, :fetched_times).by(1)
                        
      end          
      
      context 'sound of a word' do
                       
        let(:sound) {          
          Sound.create(:for_content => 'love')
        }
      
        context 'word is converted successfully to speech' do
          
          context 'word has only one sound' do
          
            it 'updates sound data and set fetched flag to true' do
                            
              sound.fetch_data
              expect(sound.mp3).not_to be_nil
              expect(sound.fetched?).to be true
              
            end
          
          end
          
          context 'word has two sounds' do
            
            before :each do
              
              allow(Network::TextToSpeech).to receive(:word_to_speech).and_return(['sound 1','sound 2']) # mimic a susscessful conversion of word to speech                           
              
            end
            
            it 'creates two other sounds and destroys itself' do                           
              
              sound.fetch_data
              
              created_sounds = Sound.where( ['for_content IN (?)', ["#{sound.for_content}@1", "#{sound.for_content}@2"]] ).to_a
                                                                   
              expect(created_sounds.count).to be 2
              
              created_sounds.each do |created_sound|
                expect(created_sound).not_to be_nil
                expect(created_sound.mp3).not_to be nil
                expect(created_sound.fetched?).to be true
              end
              
              expect {sound.reload}.to raise_exception(ActiveRecord::RecordNotFound)
              
            end
            
            it 'updates sound data for points' do                          
              
              3.Points.each do |point|
                point.update_columns :content => sound.for_content
              end
              
              sound.fetch_data
              
              created_sounds = Sound.where( ['for_content IN (?)', ["#{sound.for_content}@1", "#{sound.for_content}@2"]] ).to_a                          
              
              Point.where(['content=?', sound.for_content]).each do |point|                               
                                
                expect(created_sounds.map(&:id)).to be_include(point.sound_id)
                expect(created_sounds.map(&:id)).to be_include(point.sound2_id)
                expect(point.sound_id).not_to be point.sound2_id
                expect(point.sound_verified).to be false
                                
              end
                                         
            end
            
          end
        
        end
        
        context 'word is not converted successfully to speech' do
          
          it 'does not update sound data and does not set fetched flag to true' do
            
            allow(Network::TextToSpeech).to receive(:word_to_speech).and_return(nil)
            
            sound = Sound.create(:for_content => 'love')
            sound.fetch_data
            expect(sound.mp3).to be_nil
            expect(sound.fetched?).to be false
            
          end
          
        end
        
      end
      
      context 'sound of a phase' do
        
        let(:sound) { Sound.create(:for_content => 'I am a phase') }
        
        context 'phase is converted successfully to speech' do
        
          it 'updates sound data and set fetched flag to true' do
                        
            sound.fetch_data
            expect(sound.mp3).not_to be_nil
            expect(sound.fetched?).to be true
            
          end
        
        end
        
        context 'phase is not converted successfully to speech' do
          
          it 'does not update sound data and does not set fetched flag to true' do
            
            allow(Network::TextToSpeech).to receive(:phase_to_speech).and_return(nil)
            
            sound.fetch_data
            expect(sound.mp3).to be_nil
            expect(sound.fetched?).to be false
            
          end
          
        end
      
      end
      
    end       
    
  end
  
  describe 'callbacks' do
    
    context 'after creating' do
      
      it 'fetchs sound data' do
        
        expect_any_instance_of(Sound).to receive(:fetch_data)
          
        Sound.one
        
      end
           
    end
    
    context 'after updating' do
      
      it 'touches child points' do
        
        sound = Sound.one
        point = Point.one.belongs_to sound
        point.update_attribute :updated_at, today - 10.days
        
        sound.points.reload
        
        sound.update_attribute :updated_at, today
        
        expect(point.reload.updated_at.localtime.to_date).to eq Date.today
        
      end
      
      it 'touches child examples' do
        
        sound = Sound.one

        example = Example.one.belongs_to sound

        example.update_attribute :updated_at, today - 10.days
        
        sound.examples.reload
        
        sound.update_attribute :updated_at, Date.today
                
        expect(example.reload.updated_at.localtime.to_date).to eq Date.today
        
      end
      
    end
    
  end
  
end