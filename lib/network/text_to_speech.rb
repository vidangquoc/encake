require 'open-uri'

module Network
  
  class TextToSpeech     
    
    def self.word_to_speech(word)
            
      word_sound_url = 'http://ssl.gstatic.com/dictionary/static/sounds/de/0/{word}.mp3'
      word_sound_url1 = 'http://ssl.gstatic.com/dictionary/static/sounds/de/0/{word}@1.mp3'
      word_sound_url2 = 'http://ssl.gstatic.com/dictionary/static/sounds/de/0/{word}@2.mp3'
            
      content = get_url_content( word_sound_url.sub("{word}", word) )

      if content

        content

      else

        content1 = get_url_content( word_sound_url1.sub("{word}", word) )
        content2 = get_url_content( word_sound_url2.sub("{word}", word) )
        
        if (content1 && content2)
            
          [content1, content2]
        
        end

      end                         
                 
    end
    
    def self.phase_to_speech(phase)
      
      return nil #temporarily because google has restricted accessing to their tts engine
      
      phase_sound_url = 'http://translate.google.com/translate_tts?tl=en&q={phase}'
      
      get_url_content( phase_sound_url.sub( "{phase}", CGI.escape(phase) ) )
      
    end
    
    def self.get_url_content(url)
      open(url).read || nil
    rescue         
    end  
    
  end
  
end





