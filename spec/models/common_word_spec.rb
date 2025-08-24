require 'spec_helper'

RSpec.describe CommonWord, type: :model do
  
  describe "validations" do
    it{is_expected.to validate_presence_of :content}
  end
  
  describe "methods" do
    
    describe "parse_text" do
      
      it "extracts and stores words that do not exist in the database" do
        
        CommonWord.create! content: "existed"
        
        text = "not-existed existed"
        
        CommonWord.parse_text(text)
        
        expect(CommonWord.where(content: "existed").count).to be 1
        
        expect(CommonWord.where(content: "not-existed").count).to be 1
        
      end
      
      it "stores a new word with the line that contains the new word and two lines around it" do
        
        lines = ["some line", "previous line", "line containing new-word", "next line", "some other line"]
        
        text = lines.join("\n")
        
        CommonWord.parse_text(text)
        
        inserted_word = CommonWord.find_by content: "new-word"
        
        expect(inserted_word).not_to be nil
        
        expect(inserted_word.context).to match(/previous line/)
        
        expect(inserted_word.context).to match(/line containing new-word/)
        
        expect(inserted_word.context).to match(/next line/)
        
      end
      
    end
    
    describe "find_meanings" do
      
      before :each do
          @word = CommonWord.create! content: "international"
      end
      
      context "meanings found" do
        
        before :each do
          @word.find_meanings
        end
      
        it "fetchs the right meanings" do
          expect(@word.common_word_meanings.any?{|item| item.word_type == "adj" and item.meaning =~ /quốc tế/}).to be true
          expect(@word.common_word_meanings.any?{|item| item.word_type == "n" and item.meaning =~ /cuộc thi đấu quốc tế/}).to be true
        end
        
        it "sets meaning_fetched to true" do
          expect(@word.meaning_fetched).to be true
        end
        
        it "increases meaning_finding_times" do
          expect(@word.meaning_finding_times).to eq 1
        end
        
      end
      
      context "no meanings found" do
        
        before :each do
          allow(Network::WordMeaning).to receive(:fetch_for).and_return([])
          @word.find_meanings
        end
        
        it "does not set meaning_fetched to true" do
          expect(@word.meaning_fetched).to be false
        end
        
        it "increases meaning_finding_times" do
          expect(@word.meaning_finding_times).to eq 1
        end
        
      end
      
    end
        
  end
  
end
