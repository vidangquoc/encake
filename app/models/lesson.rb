class Lesson < ActiveRecord::Base
    
  acts_as_list scope: :syllabus
  
  strip_attributes collapse_spaces: true
    
  validates :name, {
    :presence => true    
  }
  
  validates :content, {
    :presence => true
  }
  
  validates :syllabus_id, {
    :presence => true    
  }
  
  belongs_to :syllabus
  belongs_to :master_lesson, class_name: 'Lesson', foreign_key: 'master_lesson_id'
  has_many :grammar_points
  has_many :right_answer_explanations
  has_many :points
  has_many :questions, :through => :points
  has_many :examples, :through => :points
  
  scope :active, -> { where ["active = ?", true] }
  scope :within_syllabus, ->(syllabus_id) { where ["syllabus_id = ?", syllabus_id] }
  scope :position_ascending, -> { order('position ASC') }
  scope :position_greater_than, ->(position) { where ["position > ?", position] }
  
  #after_save :expire_page_cache
    
  def next_active
    
    next_active_lesson = Lesson.active.within_syllabus(self.syllabus_id).position_greater_than(self.position).position_ascending.first
    
    if next_active_lesson.nil?
      
      next_syllabus = self.syllabus.next
      
      next_active_lesson =  next_syllabus.first_active_lesson if !next_syllabus.nil?
      
    end
    
    next_active_lesson
    
  end
  
  def process_content_for_show
    
    self.content = master_lesson.content if !master_lesson.nil?
    
    strip_excluded_content
    
    tooltipize_content
    
  end
  
  def highlight_new_words_in_content    
    highlight_words_in_content find_new_words_in_content    
  end
  
  def word_count
    find_new_words_in_content.count
  end  
  
  def extract_new_words_and_examples_from_content
    result = []
    new_words = find_new_words_in_content
    compact_content = normalize_content
    compact_content = strip_content_not_for_new_word_searching(compact_content) #exclude all content in ((( and )))
                      
    new_words.each do |word|
      example = compact_content.match(/^.*#{word}.*$/i)[0].strip rescue nil
      result.push({word: word, example: example.gsub('((', '').gsub('))', '').squeeze(' ').strip})
    end
    result
  end
  
  def import_new_words(file)
    
    return {status: :nook, message: 'Please upload a file.'} if file.nil?
    
    file_path = file.respond_to?(:path) ? file.path : file   
    extension = File.extname(file.respond_to?(:path) ? file.original_filename : file_path )
       
    return {status: :nook, message: 'Please upload a yaml file.'} if extension != '.yaml'
    
    begin 
    
      words = YAML.load(File.read file_path)
      
      transaction do
      
        words.each do |key, word_data|
          
          point = points.build(
                                content: word_data['word']['content'],
                                split_content: word_data['word']['split_content'],
                                meaning: word_data['word']['meaning'],
                                point_type: word_data['word']['type'],
                                is_supporting: word_data['word']['is_supporting'] || false
                              )
          if !point.save()
            raise "Point is invalid: #{point.errors.messages.first}. Point: #{point.inspect}"
          end
          
          if !word_data['example'].nil?
            example = point.examples.build(content: word_data['example']['content'], meaning: word_data['example']['meaning'])
            if(!example.save())
              raise "Example is invalid: #{example.errors.messages.first}. Example: #{example.inspect}"
            end
            if !word_data['example']['alternatives'].nil?
              word_data['example']['alternatives'].to_s.split('|').map(&:strip).each do |alternative|
                example.alternatives.create! content: alternative
              end
            end
          end 
          
          if !word_data['question'].nil?
            question = point.questions.build(
                                              content: word_data['question']['content'],
                                              question_type: word_data['question']['question_type'],                                              
                                              right_answer_explanation: word_data['question']['right_answer_explanation'],
                                            )
            
            if question.question_type != 'choosing'
              question.answer = word_data['question']['right_answer']
            end
            
            if !question.save()
              raise "Question is invalid: #{question.errors.messages.first}, Question: #{question.inspect}"
            end

            word_data['question']['answers'].to_s.split('|').map(&:strip).each do |answer_content|
              answer = question.answers.create! content: answer_content
              question.update_attribute(:right_answer, answer) if answer_content == word_data['question']['right_answer']
            end
            
          end
                    
          word_data['variations'].to_s.split('|').map(&:strip).each do |variation|
            point.variations.create content: variation
          end         
          
        end
                
      end
    
    rescue Exception => e
      return {status: :nook, message: e.message }
    end
    
    return {status: :ok}
    
  end
  
  def find_new_words_in_content
    
    looked_in_content = normalize_content
    looked_in_content = strip_content_not_for_new_word_searching(looked_in_content) #exclude all content in ((( and )))
                                                
    special_phases = looked_in_content.scan(/\(\([^(]*\)\)/)
    
    special_phases = Hash[special_phases.each_with_index.map{|phase, index| ["special-phase-#{index_to_unique_string(index)}", phase]}]
    
    special_phases.each_pair{|key, phase| looked_in_content = looked_in_content.sub(phase, key)}
    
    new_words = find_new_words_in_text(looked_in_content)
    
    special_phases.each_pair do |key, phase|
      
      phase = phase.sub('((', '').sub('))', '').squeeze(' ').strip
      
      new_words[new_words.index(key)] = find_new_words_in_text(phase) + [phase]
      
    end
    
    new_words.flatten.map(&:downcase).uniq{|word| word.singularize}
    
  end
  
  private
  
  def strip_excluded_content
        
    self.content = strip_content_within(self.content, '[[[', ']]]')
    
  end
  
  def tooltipize_content
    
    tooltipized_content = content
    
    open_index = close_index = 0
    
    while open_index and close_index
      open_index = tooltipized_content.index('[[')
      close_index = tooltipized_content.index(']]')
      if open_index and close_index
        tooltip_title = ActionView::Base.full_sanitizer.sanitize(tooltipized_content[open_index + 2, close_index - open_index- 2])
        tooltip = "<a class='btn btn-xs btn-info vi-tip' data-toggle='tooltip' data-placement='top' data-trigger='click hover' data-content='#{tooltip_title}' x-tooltip >vi</a>"
        tooltipized_content[open_index, close_index - open_index + 2] = tooltip
      end
    end
    
    self.content = tooltipized_content
    
  end
  
  def find_new_words_in_text(text)
    
    new_words = []
    
    words = text
            .split(/\s+/) # split content by space characters
            .collect{|item| item.sub(/^.*>(?=\w)/,'')} #remove leading html tags from words
            .collect{|item| item.sub(/<.*$/,'')} # remove  trailing html tags from words
            .select {|item| item =~ /^[A-Za-z\-]+([.,:!?])?$/} # keeps only character containing A-Z,a-z and punctuation characters
            .collect{|item| item.scan(/[A-Za-z\-]+/).first } # remove punctuation characters from words
            .compact
           
    words.each do |word|
      if Point.find_by(content:word, is_private: false).nil? and WordVariation.find_by(content:word).nil?
        new_words.push(word)
      end    
    end
    
    new_words
    
  end
  
  def normalize_content    
    ActionView::Base.full_sanitizer.sanitize(content).gsub('&nbsp;',' ').gsub('&#39;','\'').gsub('&amp;#39;','\'')
  end  
  
  def highlight_words_in_content(words)
    
    highlighted_content = strip_content_not_for_new_word_searching(content)
    
    special_phases = highlighted_content.scan(/\(\([^(]*\)\)/)
    
    special_phases.each_with_index{|phase, index| highlighted_content = highlighted_content.sub(phase, "((#{index}))")}
    
    words.each do |word|
      highlighted_content.sub!(/(^|[^A-Za-z<])(#{word})([^A-Za-z>]|$)/i, '\1<highlight>\2</highlight>\3')
    end
    
    special_phases.each_with_index{|phase, index| highlighted_content = highlighted_content.sub(  "((#{index}))", phase.sub(/(\(\()([^\(\)]*)(\)\))/, '\1<highlight>\2</highlight>\3')  )}
    
    highlighted_content
    
  end
  
  def index_to_unique_string(index)
    index.to_s.chars.map{|char| number_to_word(char.to_i)}.join('-')
  end
  
  def number_to_word(number)
    case number
    when 0 then 'zero'
    when 1 then 'one'
    when 2 then 'two'
    when 3 then 'three'
    when 4 then 'four'
    when 5 then 'five'
    when 6 then 'six'
    when 7 then 'seven'
    when 8 then 'eight'
    when 9 then 'nine'
    end
  end
  
  def strip_content_not_for_new_word_searching(content)
    strip_content_within(content, '(((', ')))')
  end
  
  def strip_content_within(content_to_strip, open_string, close_string)
    
    raise "Open string and close string must have the same length" if open_string.length != close_string.length
    
    stripped_content = content_to_strip
    
    open_index = close_index = 0
    
    while open_index and close_index
      open_index = stripped_content.index(open_string)
      close_index = stripped_content.index(close_string)
      stripped_content[open_index, close_index + open_string.length - open_index] = '' if open_index and close_index
    end
    
    stripped_content
    
  end
  
end
