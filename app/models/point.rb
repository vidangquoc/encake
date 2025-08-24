class Point < ActiveRecord::Base
  
  strip_attributes collapse_spaces: true
  strip_attributes only: :split_content, regex: /\s/
  
  acts_as_list scope: :lesson
  
  POINT_TYPES = {
    n:      'Danh Từ', # Noun
    v:      'Động Từ', # Verb
    adv:    'Trạng Từ', # Adverb
    adj:    'Tính Từ', # Adjective
    prep:   'Giới Từ', # Preposition
    exp:    'Thành Ngữ', # Expression
    prn:    'Danh Từ Riêng', # Proper Name
    pron:   'Đại Từ', # Pronoun
    dadj:   'Tính Từ Chỉ Định', # Demonstrative Adjective
    art:    'Mạo Từ', # Article
    conj:   'Liên Từ', # Conjunction
    interj: 'Thán Từ', # Interjection
  }
  
  validates :content, {
    :presence => true
  }
  
  validates :lesson_id, {
    :presence => true
  }
  
  validates :meaning, {
    :presence => true
  }
  
  validates :point_type, {
    :presence => true
  }
  
  belongs_to :lesson
  belongs_to :sound
  belongs_to :sound2, :class_name => 'Sound', :foreign_key => 'sound2_id'
  belongs_to :main_example, :class_name => 'Example', :foreign_key => 'main_example_id'
  
  has_many :questions, dependent: :destroy
  has_many :examples, dependent: :destroy
  has_many :reviews, dependent: :destroy
  has_many :review_skills, through: :reviews
  has_many :variations, class_name: 'WordVariation', dependent: :destroy
  has_many :valid_questions, -> {where :is_valid => true}, :class_name => 'Question'
  has_one :first_example, :class_name => 'Example', :foreign_key => 'point_id'
  has_one :first_valid_question, -> {where is_valid: true}, class_name: 'Question', foreign_key: 'point_id'
  has_many :example_point_links, dependent: :destroy
  has_many :linked_examples, through: :example_point_links, source: :example, class_name: 'Example'
  has_many :images, class_name: 'PointImage'
  
  
  accepts_nested_attributes_for :main_example
  
  scope :includes_for_review, -> { includes(:sound).includes(main_example: [:sound, :grammar_point, :alternatives]).includes(first_valid_question: :answers) }
  
  scope :includes_for_search_by_user, -> { includes(:sound).includes(main_example: [:sound]) }
  
  after_create :find_pronunciation
  
  after_update :update_pronunciation
  after_update :check_if_main_example_changed, :check_if_position_changed
   
  after_save :update_sound, :touch_lesson
  
  def random_example()
    examples.sample
  end
  
  def self.point_types
    POINT_TYPES.map{|abbriviation, type| [type, abbriviation] }
  end
  
  def update_validity
    
    if !main_example.nil? and valid_questions.any?
      
      update_column :is_valid, true #skip callbacks
      
    else
      
      update_column :is_valid, false #skip callbacks
      
    end
    
  end
  
  private
  
  def update_sound
        
    if content_changed?
      
      previous_sound = Sound.find_by_id(sound_id_was)
      
      find_sound
                
      previous_sound.destroy if previous_sound and ! Point.exists? ['sound_id=?', previous_sound.id]
      
    end  
    
  end
    
  def find_sound

    if self.skip_finding_sound
      return
    end
    
    return if self.is_private and self.point_type == 'exp'
    
    sound = Sound.find_by_for_content(self.content)
    
    if sound.nil?
      sound = Sound.where(['for_content = ? OR for_content = ?', "#{self.content}@1", "#{self.content}@2"]).to_a
      sound = nil if sound.empty?
    end
    
    if sound.instance_of?(Array)
      
      self.update_column('sound_id', sound[0].id) #skip callbacks
      self.update_column('sound2_id', sound[1].id) #skip callbacks
      self.update_column('sound_verified', false) #skip callbacks
      
    elsif ! sound.nil?
           
      self.update_column('sound_id', sound.id) #skip callbacks
      
    else           
      
      new_sound = Sound.create(:for_content => self.content)
      self.update_column('sound_id', new_sound.id) #skip callbacks
      
    end
  end
  
  def update_pronunciation
    
    if content_changed? && !self.is_private?
            
      update_columns pronunciation: nil, possible_pronunciations: nil #skip callbacks
      find_pronunciation
      
    end
    
  end
  
  def find_pronunciation

    if self.skip_finding_pronunciation
      return 
    end

    if self.pronunciation.blank? && !self.is_private?
      pronunciations = Network::WordPronunciation.fetch_for(self.content)
      update_columns pronunciation: pronunciations[:valid_pronunciation], possible_pronunciations: pronunciations[:possible_pronunciations].join(' <-> ') #skip callbacks
    end
  end
  handle_asynchronously :find_pronunciation  
  
  def check_if_main_example_changed
       
    if main_example_id_changed?      
      
      update_validity
      
    end
    
  end
  
  def check_if_position_changed
    insert_at position if position_changed?
  end
  
  def touch_lesson
    lesson.update updated_at: DateTime.now if !lesson.nil?
  end
    
end

class << Point
  
  def find_highest_lesson_in_points(point_ids)
    Lesson
    .joins(:points)
    .select("lessons.id, lessons.position")
    .where(['points.id IN (?)', point_ids])
    .order('lessons.position DESC')
    .first    
  end
  
  def get_by_ids(ids)
    Point.where(id:ids).sort_by{|point| ids.index(point.id)}
  end
  
  def is_word?(string)
    (/^(?=[a-z])([a-z_\-]*)[a-z]$/ =~ string) ? true : false
  end
  
  def is_phase?(string)
    ! is_word?(string)
  end
  
  def search_by_user(user_id, options = {})
    
    user_id = user_id.to_i
    content = options[:content]
    search_in = options.fetch(:search_in, :all)
    
    raise "Invalid value for search_in" if ! [:all, :user_bag, :added_by_user].include?(search_in)
    
    query = Point.select("points.*, IF(reviews.id IS NULL , 0, 1) AS is_in_bag")
    query = query.joins("LEFT JOIN reviews ON reviews.point_id = points.id AND reviews.user_id = #{user_id} AND reviews.is_active = 1")
    query = query.where(["points.is_private = ? OR (points.is_private = ? AND points.adding_user_id = ?)", false, true, user_id])
    query = query.where(["points.content like ?", "%#{content}%"]) if !content.blank?
    query = query.where(['reviews.user_id = ?', user_id]) if search_in == :user_bag
    query = query.where(adding_user_id: user_id) if search_in == :added_by_user
    
    query
    
  end
  
  def search_including_variations(key, user_id)
    
    key = tidy_up_key_for_searching(key)
    
    #search words matching key or words that have variations matching key
    words_with_content_matches = Point.select(:id).where(["points.content = ?",  key]).where(["point_type <> 'exp'"])
    words_with_variation_matches = Point.joins(:variations).select("points.id").where(["word_variations.content = ?", key]).where(["point_type <> 'exp'"])
    word_ids = words_with_content_matches.map(&:id) + words_with_variation_matches.map(&:id)
                
    #search expressions that contain key, or contain words that have key as variations , or contains variations that have key as parent words, limit result set to 100
    words = Point.joins(:variations)
            .select("points.content")
            .where(["word_variations.content = ?", key])
            .map(&:content)
    
    word_variations = Point.joins(:variations)
                      .select("word_variations.content")
                      .where(["points.content IN (?)", words.push(key) ])
                      .map(&:content)
                      
    expression_keys = (words + word_variations).uniq.push(key)
    
    conditions = expression_keys.map do |expression_key|
      "(content LIKE ? OR content LIKE ? OR content LIKE ?)"
    end.join(' OR ')
    
    expression_ids = Point.where(point_type: 'exp').where([  conditions, *expression_keys.map{|exp| ["% #{exp} %", "#{exp} %", "% #{exp}"] }.flatten  ]).limit(200).map(&:id)
    
    #merge results
    points = Point.includes_for_search_by_user
            .where(id: word_ids).where(["points.is_private = ? OR (points.is_private = ? AND points.adding_user_id = ?)", false, true, user_id])
            .order('content asc, point_type')
            .to_a
            
    expressions = Point.includes_for_search_by_user
                  .where(id: expression_ids).where(["points.is_private = ? OR (points.is_private = ? AND points.adding_user_id = ?)", false, true, user_id])
                  .order('content asc')
                  .to_a
    
    points + expressions
    
  end
  
  def build_by_user_with_example(user_id, attributes)
    
    built_point = Point.new(attributes)

    built_point.adding_user_id = user_id
    
    built_point.lesson_id = -1
    
    built_point.is_private = true
    
    built_point.main_example.point_id = -1
    
    built_point.main_example.grammar_point_id = -1
    
    built_point
    
  end
  
  def save_by_user_with_example(user_id, point)      
    
    ActiveRecord::Base.transaction do
      
      point.save!
      
      point.main_example.update_attributes point_id: point.id, is_main: true
      
      add_point_for_user(point.id, user_id)
      
    end
    
  end
  
  def add_point_for_user(point_id, user_id)
    point = Point.find(point_id)
    existing_review = Review.find_by(point_id: point, user_id: user_id)
    if existing_review.nil?
      transaction do
        review = Review.create point_id: point_id, user_id: user_id
        ReviewSkill.import ReviewSkill.build_skills_for_review(review)
      end
    else
      existing_review.update_attribute :is_active, true
    end
  end
  
  private
  
  def tidy_up_key_for_searching(key)
    
    key = key.to_s
    
    if %w{mr. mrs. ms. a.m. p.m.}.any?{|item| item == key.downcase }
      return key
    end
    
    key = key.gsub(/[^0-9a-zA-z_\-]+$/, '')
    
    if Contraction.where(content: key).any?
      key
    else
      key.gsub(/'s?/, '')
    end
    
  end
  
end