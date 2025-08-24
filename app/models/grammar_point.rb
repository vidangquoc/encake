class GrammarPoint < ActiveRecord::Base
  
  strip_attributes collapse_spaces: true
  
  validates :lesson_id, presence: true
  
  validates :content, presence: true
    
  belongs_to :lesson
  
  has_many :examples
  
  after_update :touch_examples  
  
  def self.the_grammar_point_with_the_less_examples(excluded_grammar_point_ids=[])
    
    query = GrammarPoint
            .joins(:examples)
            .references(:examples)
            .select("grammar_points.id, count(examples.id) as example_count")
            .group('grammar_points.id')
            .order('example_count ASC')
    
    if excluded_grammar_point_ids.any?
      query = query.where(['grammar_points.id NOT IN (?)', excluded_grammar_point_ids])
    end
    
    grammar_point = query.first      
    
    grammar_point.nil? ? nil : GrammarPoint.find(grammar_point.id)
    
  end
  
  private
  
  def touch_examples
    examples.each {|example| example.update_attribute :updated_at, DateTime.now }
  end
  
end
