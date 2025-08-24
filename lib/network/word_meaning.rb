module Network
  class WordMeaning
  end
end

class << Network::WordMeaning
  
  def fetch_for(word)
    
    #web_content = File.read(Rails.root.join("spec/factories/sample_files/love.html"))
    url = "https://vdict.com/word?word=#{CGI.escape(word)}"
    web_content = open(url).read || nil
    
    return [] if web_content.nil? || !page_header_matches_word?(web_content, word)
    
    create_meanings_from_related_nodes( get_meaning_related_nodes(web_content) )
    
  end
  
  private
  
  def get_meaning_related_nodes(web_content)
       
    nodes = []
    
    Nokogiri::HTML.parse(web_content).css("#result-contents>*").each do |node|
      if node.element?
        if (node.name == "div" and node["class"] =~ /phanloai/) || (node.name == "ul" and node["class"] =~ /list1/ and node.at_css('.idiom-meaning').nil?)
          nodes << node
        end
      end
    end
    
    nodes
    
  end
  
  def create_meanings_from_related_nodes(nodes)
    
    meanings = []
    type_name = ""
    
    nodes.each do |node|
      if node["class"] =~ /phanloai/
        type_name = node.content.strip
      elsif node["class"] =~ /list1/
        meaning = {}
        meaning[:type_name] = type_name
        meaning[:meaning] = node.at_css("li").inner_html
        meanings << meaning
      end
    end
    
    meanings
    
  end
  
  def page_header_matches_word?(web_content, word)
    header = Nokogiri::HTML.parse(web_content).at_css('.word_title').content.strip rescue ''
    header == word.strip
  end
  
end