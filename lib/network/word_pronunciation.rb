module Network
  
  class WordPronunciation
    
    class << self        
    
      def fetch_for(word)
              
        possible_pronunciations = fetch_from_thefreedictionary(word)
        
        valid_pronunciations = possible_pronunciations.select{|pron| (pron.split('') - valid_pronunciation_characters).length == 0}
        
        if valid_pronunciations.length != 1
          valid_pronunciations = fetch_from_vdict(word)          
        end
              
        {
          possible_pronunciations: possible_pronunciations,
          valid_pronunciation: valid_pronunciations.length == 1 ? valid_pronunciations.first : nil
        }      
        
      end
      
      private
      
      def fetch_from_thefreedictionary(word)
                
        pronunciations = []
        
        url = "http://thefreedictionary.com/#{CGI.escape(word)}" 
        web_content = open(url).read || nil
           
        if !web_content.nil? 
          pronunciations = Nokogiri::HTML.parse(web_content).css(".pron").map{|node| node.content.strip.sub('(', '').sub(')', '').gsub(/\s/,'').strip}.uniq
        end
        
        pronunciations
        
      end
      
      def fetch_from_vdict(word)
        
        url = "http://vdict.com/word?word=#{CGI.escape(word)}"
        web_content = open(url).read || nil
        pronunciations = Nokogiri::HTML.parse(web_content).css(".pronounce").map{|node| node.content.strip.gsub('/', '').gsub(/\s/,'').strip}.uniq
        
        pronunciations
        
      end
      
      def valid_pronunciation_characters
        %w{ˈ ˌ ʌ ɑ ː æ e ə ɜ ʳ ɪ i ɒ ɔ ʊ u a o b d f g h j k l m n ŋ p r s ʃ t θ ð v w z ʒ}
      end
      
    end
    
  end
  
end