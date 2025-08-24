def detect_strange_words_in_examples()
  
  words_in_examples = []
  
  Example.joins(:point).where(["points.is_valid = ?", true]).each do |example|
    words_in_examples.push(example.content.split(/\s/))
  end
  
  words_in_examples = words_in_examples.flatten.uniq.map{|w| (Point.send :tidy_up_key_for_searching, w).downcase }.uniq
  
  words = Point.select('content').where(is_private: false).map(&:content).uniq.map(&:downcase)
  
  variations = Point.select('word_variations.content').joins(:variations).where(is_private: false).map(&:content).uniq.map(&:downcase)
  
  words_in_examples - words - variations
  
end