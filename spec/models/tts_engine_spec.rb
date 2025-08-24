require_relative '../spec_helper'

describe Network::TextToSpeech do  
  
  describe 'word_to_speech method' do
    
    it 'returns audio string of the converted word' do
      
      result = Network::TextToSpeech.word_to_speech('love')
      expect(result).to be_a String
      expect(result).not_to be_nil
      
    end
    
    it 'returns an array containing audio strings of the converted word if the word have two audio versions' do
      
      result = Network::TextToSpeech.word_to_speech('desert')
      expect(result).to be_an(Array)
      expect(result.count).to be 2
      expect(result[0]).to be_a String
      expect(result[0]).not_to be_nil
      expect(result[1]).to be_a String
      expect(result[1]).not_to be_nil
      
    end
    
    it 'returns nil if the word has no audio version' do
      
      expect(Network::TextToSpeech.word_to_speech('not_a_word')).to be_nil  
      
    end
    
  end
  
  describe 'phase_to_speech method' do
    
    pending 'returns audio string of the converted phase' do
      
      result = Network::TextToSpeech.phase_to_speech('I love you')
      expect(result).to be_a String
      expect(result).not_to be_nil
      
    end
    
  end  
  
end  