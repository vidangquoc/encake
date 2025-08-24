require 'spec_helper'

describe Lesson do
  
  before :each do
    allow(Network::TextToSpeech).to receive(:word_to_speech).and_return(nil)
    allow(Network::TextToSpeech).to receive(:phase_to_speech).and_return(nil)
    allow(Network::WordPronunciation).to receive(:fetch_for).and_return({possible_pronunciations: [], valid_pronunciation: nil});
  end
  
  describe 'validations' do
    
    subject do
      FactoryBot.create :lesson
    end      
    
    it { is_expected.to validate_presence_of :name }
    
    it { is_expected.to validate_presence_of :content }
    
    it { is_expected.to validate_presence_of :syllabus_id }
    
  end
  
  describe 'methods' do    
    
    describe 'next_active' do
      
      before :each do
        
        @syllabus = Syllabus.one
        
        @lesson1, @lesson2, @lesson3 = 3.Lessons.belongs_to([@syllabus])
        
        @lesson2.update_attribute :active, false
        
      end
      
      it 'returns the next active lesson of the same syllabus' do
                             
        expect(@lesson1.next_active.id).to be @lesson3.id
        
      end
      
      it "returns the first active lesson of the next syllabus if the lesson is the last active lesson of it's syllabus" do
        
        @lesson3.update_attribute :active, false # to make lesson 1 is the last active lesson of the @syllabus
         
        @syllabus2 = Syllabus.one
       
        3.Lessons.belongs_to([@syllabus2])
                                      
        @first_active_lesson_of_the_second_syllabus = @syllabus2.lessons.active.last
        @first_active_lesson_of_the_second_syllabus.move_to_top
        
        expect(@lesson1.next_active.id).to be @first_active_lesson_of_the_second_syllabus.id
        
      end
      
      it "returns nil if the lesson is the last active lesson of the last syllabus" do
        
        expect(@lesson3.next_active).to be nil
        
      end
      
    end
    
    describe 'highlight_new_words_in_content' do
      
      before :each do
        Point.has([{content: 'existed'}]).belongs_to(1.Lesson)
        @lesson = Lesson.one
      end
      
      it 'highlights new words' do
        @lesson.content= "existed new"
        expect(@lesson.highlight_new_words_in_content).to eq "existed <highlight>new</highlight>"
      end
      
      it 'highlights new words case-insensitively' do
        @lesson.content= "existed NeW"
        expect(@lesson.highlight_new_words_in_content).to eq "existed <highlight>NeW</highlight>"
      end
      
      it 'does not highlight existing words' do
        @lesson.content= "existed new"
        expect(@lesson.highlight_new_words_in_content).not_to include("<highlight>existed</highlight>")
      end
      
      it 'highlight existing private words' do
        @lesson.content= "existed new"
        Point.where({content: 'existed'}).update_all is_private: true
        expect(@lesson.highlight_new_words_in_content).to include("<highlight>existed</highlight>")
      end
      
      it 'does not highlight words that exist in list of word variations' do
        FactoryBot.create :word_variation, content: 'a'
        @lesson.content = 'a cat'
        expect(@lesson.highlight_new_words_in_content).to eq "a <highlight>cat</highlight>"
      end
      
      it 'hightlights new words only once' do
        @lesson.content= "existed new new"
        expect(@lesson.highlight_new_words_in_content).to eq "existed <highlight>new</highlight> new"
      end
      
      it 'hightlights new words only once incasitively' do
        @lesson.content= "existed new New"
        expect(@lesson.highlight_new_words_in_content).to eq "existed <highlight>new</highlight> New"
      end
      
      it 'does not highlight a new word within a word' do
        @lesson.content= "existed exist"
        expect(@lesson.highlight_new_words_in_content).not_to eq "<highlight>exist</highlight>ed exist"
      end
      
      it 'keeps word with non-ascii characters unchanged' do
        @lesson.content= "specialà"
        expect(@lesson.highlight_new_words_in_content).to eq @lesson.content
      end
      
      it 'highlights word followed by html tags properly' do
        @lesson.content= "new</strong>"
        expect(@lesson.highlight_new_words_in_content).to eq "<highlight>new</highlight></strong>"
      end
      
      it 'highlights word preceded by html tags properly' do
        @lesson.content= "<strong>new"
        expect(@lesson.highlight_new_words_in_content).to eq "<strong><highlight>new</highlight>"
      end
      
      it 'does not highlight html tags' do
        @lesson.content= "<strong> strong"
        expect(@lesson.highlight_new_words_in_content).to eq "<strong> <highlight>strong</highlight>"
      end
            
      it 'hightlights only the first occurrence of a noun despite its singular/plural form' do
        @lesson.content = "mango mangoes"
        expect(@lesson.highlight_new_words_in_content).to eq "<highlight>mango</highlight> mangoes"
      end
      
      it 'highlight words with dashes correctly' do
        @lesson.content = "hard-working"
        expect(@lesson.highlight_new_words_in_content).to eq "<highlight>hard-working</highlight>"
      end
      
      it 'exclude content in ((( and )))' do
        @lesson.content = "(((\n no highlight \n))) highlight"
        expect(@lesson.highlight_new_words_in_content).to eq " <highlight>highlight</highlight>"
      end
      
      it 'highlights phase in (( and ))' do
        @lesson.content = "(( existed phase ))"
        expect(@lesson.highlight_new_words_in_content).to eq "((<highlight> existed phase </highlight>))"
      end
      
    end
    
    describe 'extract_new_words_and_examples_from_content' do
      
      before :each do
        %w{this is a and some}.map{ |existed_word| FactoryBot.create :point, content: existed_word }.belongs_to(1.Lesson)
        @lesson = Lesson.one
      end
      
      it 'extracts new words with examples' do
        
        @lesson.content = <<-CONTENT
        
          This is a sentence.
          
          This is another sentence.
          
          And some sentences.
          
        CONTENT
        
        expected_result = [
          {
            word: 'sentence',
            example: 'This is a sentence.'
          },
          {
            word: 'another',
            example: 'This is another sentence.'
          }
        ]
        
        expect(@lesson.extract_new_words_and_examples_from_content).to eq(expected_result)
        
      end
      
      it 'ignores content that is in ((( and )))' do
        
        @lesson.content = <<-CONTENT
        
          ((( This is a sentence. )))
          
          This is another.     
          
        CONTENT
        
        expected_result = [         
          {
            word: 'another',
            example: 'This is another.'
          }
        ]
        
        expect(@lesson.extract_new_words_and_examples_from_content).to eq(expected_result)
        
      end
      
      it 'considers a phase in (( and )) as a new word' do
        
        @lesson.content = <<-CONTENT
        
          This (( is special))
          
        CONTENT
        
        expected_result = [         
          {
            word: 'special',
            example: 'This is special'
          },
          {
            word: 'is special',
            example: 'This is special'
          }
        ]
        
        expect(@lesson.extract_new_words_and_examples_from_content).to eq(expected_result)
        
      end
      
    end
    
    describe 'imports_new_words' do
      
      before :each do        
        @lesson = Lesson.one        
      end
      
      def imported_file_path(filename)
        Rails.root.join('spec','factories','sample_files',filename)
      end
      
      it 'imports new words correctly' do
                
        result = @lesson.import_new_words(imported_file_path 'new_words_import_valid_all.yaml')
        
        expect(result[:status]).to be :ok
        
        word1         = @lesson.points.find_by content: 'love'
        expect(word1.content).to eq('love')
        expect(word1.meaning).to eq('yêu')
        expect(word1.point_type).to eq('v')
        expect(word1.is_supporting).to be true
                
        example1      = word1.main_example
        expect(example1.content).to eq('I love you')
        expect(example1.meaning).to eq('Tôi yêu em')
        expect(example1.alternatives.map(&:content).join(',')).to eq('I love her,I love him')
        
        question1     = word1.questions.first
        expect(question1.content).to eq('I {...} you')
        expect(question1.question_type).to eq('filling_in')
        expect(question1.answers.map(&:content).join(',')).to eq('love,loves,loved')
        
        right_answer1 = question1.right_answer                            
        expect(right_answer1.content).to eq('love')
        
        expect(word1.variations.map(&:content)).to eq(['loving', 'loved'])
        
      end
      
      it 'imports words without a question' do
        
        result = @lesson.import_new_words(imported_file_path 'new_words_import_no_question.yaml')
        expect(result[:status]).to be :ok
        
      end
      
      it 'imports words without variations' do
        
        result = @lesson.import_new_words(imported_file_path 'new_words_import_no_variations.yaml')
        expect(result[:status]).to be :ok
        
      end
      
      it 'imports words without an example' do
        
        result = @lesson.import_new_words(imported_file_path 'new_words_import_no_examples.yaml')
        expect(result[:status]).to be :ok
        
      end
      
      it 'complains if file extension is not .yaml' do
        
        result = @lesson.import_new_words('file.not_yaml')
        expect(result[:status]).to be :nook
        expect(result[:message]).to match(/yaml/)
        
      end
      
      it 'requires that a file is provided' do
        result = @lesson.import_new_words(nil)
        expect(result[:status]).to be :nook
        expect(result[:message]).to match(/a file/)
      end
            
    end
    
    
    #describe 'strip_excluded_content' do
    #  it 'strips content between [[[ and ]]]' do
    #    @lesson = Lesson.one
    #    @lesson.content = "The [[[ striped content]]] is here"
    #    expect(@lesson.strip_excluded_content).to eq "The  is here"
    #  end
    #end
    
    describe 'process_content_for_show' do
      pending 'Test for method process_content_for_show'
    end
    
  end
   
  
end
