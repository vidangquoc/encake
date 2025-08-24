class CommonWord < ActiveRecord::Base
  
  strip_attributes collapse_spaces: true
  
  validates :content, {
    :presence => true
  }
  
  has_many :common_word_meanings, dependent: :destroy
  
  def find_meanings
    
    meanings = Network::WordMeaning.fetch_for(content)
    
    if meanings.any?
      
      meanings.each do |meaning|
        
        common_word_meaning = CommonWordMeaning.new({
                                                        common_word_id: self.id,
                                                        content: content,
                                                        type_name: meaning[:type_name],
                                                        word_type: CommonWordMeaning.convert_type(meaning[:type_name]),
                                                        meaning: meaning[:meaning],
                                                      })
        
        common_word_meaning.save
        
      end
      
      self.meaning_fetched = true
          
    end
    
    self.meaning_finding_times ||= 0
    
    self.meaning_finding_times += 1
    
    save
    
  end

end

class << CommonWord
  
  def parse_text(text)
    
    lines = text.split("\n");
    
    lines.each_with_index do |line, index|
      
      words = find_new_words_in_line(line)
      
      words.each do |word|
        
        CommonWord.create content: word, context: [ lines[index-1], line, lines[index+1] ].join("\n")
        
      end 
      
    end
    
  end
  
  def find_meanings_for_words()
    
    where(meaning_fetched: [false, nil], meaning_finding_times: 0).order("meaning_finding_times ASC").find_each do |word|
      word.find_meanings
      sleep rand(0..1)
    end
    
  end
  
  def extract_words(text)
    
    text
    .split(/\s+/) # split content by space characters
    .collect{|item| item.sub(/^.*>(?=\w)/,'')} #remove leading html tags from words
    .collect{|item| item.sub(/<.*$/,'')} # remove  trailing html tags from words
    .select {|item| item =~ /^[A-Za-z\-]+([.,:!?])?$/} # keeps only character containing A-Z,a-z and punctuation characters
    .collect{|item| item.scan(/[A-Za-z\-]+/).first } # remove punctuation characters from words            
    .compact
            
  end
  
  private
  
  def find_new_words_in_line(line)
    
    words = extract_words(line)
    
    new_words = []
        
    words.each do |word|
      if CommonWord.find_by(content:word).nil?
        new_words.push(word)
      end    
    end
    
    new_words.map(&:downcase).uniq{|word| word.singularize}
    
  end
  
end
