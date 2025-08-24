require 'spec_helper'

describe 'String' do
  
  describe 'parse_date method' do
    
    it 'returns a Date object given a valid date string' do
      
      'none'.parse_date == nil           
      
      expect('today'.parse_date).to eq Date.today
      
      expect("20/1/2012".parse_date).to eq Date.new(2012, 1, 20)
      
      expect("2 days from now".parse_date).to eq Date.today + 2.days
      
      expect("2 days from today".parse_date).to eq Date.today + 2.days
      
      expect("2 months from now".parse_date).to eq Date.today + 2.months
      
      expect("2 days ago".parse_date).to eq Date.today - 2.days
      
      expect("2 months ago".parse_date).to eq Date.today - 2.months
      
      expect("the day after tomorrow".parse_date).to eq Date.today + 2.days
      
    end
    
    it 'ignore extra spaces' do
      expect("the  day  after  tomorrow".parse_date).to eq Date.today + 2.days
      expect("2   days   ago".parse_date).to eq Date.today - 2.days
    end
    
  end
  
  describe 'digits_to_ascii_characters' do
    
    it 'converts string of digits to equivalent string of ascii characters' do
      
      expect("0123456789".to_ascii_characters).to eq 'abcdefghij'
      
      expect("0246813579".to_ascii_characters).to eq 'acegibdfhj'
      
    end
    
  end
  
end