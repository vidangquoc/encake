#["ʌ", "ɑ:", "æ", "e", "ə", "ɜ:ʳ", "ɪ", "i:", "ɒ", "ɔ:", "ʊ", "u:", "aɪ", "aʊ", "eɪ", "oʊ", "ɔɪ", "eəʳ", "ɪəʳ", "ʊəʳ", "b", "d", "f", "g", "h", "j", "k", "l", "m", "n", "ŋ", "p", "r", "s", "ʃ", "t", "tʃ", "θ", "ð", "v", "w", "z", "ʒ", "dʒ", "ˈ", "ʳ", "i", "əl", "ən"]

valid_pronunciation_charactors = %w{ʌ ɑ ː æ e ə ɜ ʳ ɪ i ɒ ɔ ʊ u a o b d f g h j k l m n ŋ p r s ʃ t θ ð v w z ʒ ˈ}
valid_pronunciations = []

#web_content = File.read(Rails.root.join('spec/factories/sample_files/beautiful.html'))
content = 'beautiful'
url = "http://thefreedictionary.com/beautiful"
web_content = open(url).read || nil

doc = Nokogiri::HTML.parse(web_content)
doc.css(".pron").each do |node|
  prop = node.content.strip.sub('(', '').sub(')', '')
  puts prop
  valid_pronunciations.push(prop) if (prop.split('') - valid_pronunciation_charactors).length == 0  
end

ap valid_pronunciations

