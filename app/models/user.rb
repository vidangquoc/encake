class User < ActiveRecord::Base  
  
  attr_accessor :birthday_day, :birthday_month, :birthday_year, :password, :recovering_password, :auth_token, :avatar_cropping_data
      
  MONTHS = (1..12).collect {|month| [month, month]}  
  DAYS = (1..31).collect {|day| [day, day] }
  START_YEAR = Time.now.year - 100
  END_YEAR = Time.now.year
  YEAR_RANGE = START_YEAR..END_YEAR
  GENDERS = ['male', 'female']
  STATUSES = {:not_confirmed=>0, :active => 1}
  EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  USER_TYPES = ['normal','tester','new_change_eager']
  
  validates :email, {
    :presence => true,
    :format => {:with => EMAIL_FORMAT },
    :uniqueness => {:case_sensitive => false}
  }
      
  validates :password, {
    :presence => true,
    :length => {:minimum => 5, :maximum => 100},
    :format => {:with =>/\A[\x00-\x7F]*\z/ },
    :confirmation => {on: :update},
    :if => ->(o){o.new_record? or o.password.present? }
  }
  
  validates :gender, {
    :presence => {on: :update},
    :inclusion => {:in => GENDERS, allow_blank: true}
  }
  
  validates :first_name, {
    :presence => true   
  }
  
  validates :last_name, {
    :presence => true  
  }
  
  validates :image_of_beloved, {
    :presence => true, on: :image_of_beloved_uploader
  }
  
  validates :relationship_to_beloved, {
    presence: true, on: :image_of_beloved_uploader
  }
  
  validates :user_type, {
    :inclusion => {:in => USER_TYPES}
  }
  
  has_many :invitations, :foreign_key => 'sender_id'
  #
  has_many :friendships, :dependent => :destroy
  has_many :friends, :through => :friendships
  has_many :inverse_friendships, :class_name => "Friendship", :foreign_key => "friend_id", :dependent => :destroy
  has_many :inverse_friends, :through => :inverse_friendships, :source => :user
  has_many :authentication_tokens
  #
  belongs_to :level
  
  has_many :reviews, :autosave => true, :dependent => :destroy
  has_many :points, :through => :reviews
  has_many :review_skills, through: :reviews
  #
  belongs_to :current_lesson, :class_name => 'Lesson', :foreign_key => 'current_lesson_id'
  #
  has_many :device_keys
  
  scope :best_studying, -> { order('score DESC') }  
  scope :with_ids, ->(ids){ ids.any? ? where(['users.id IN (?)', ids]) : User }
 
  before_create :create_confirmation_hash, :initialize_level, :initialize_current_lesson
  
  mount_uploader :avatar, AvatarUploader
    
  def points_for_review(number_of_points)

    review_skill_ids = review_skills
                      .due                      
                      .where(["reviews.is_active = ?", true])
                      .limit(number_of_points).map(&:id)
    
    Point.select("points.*, #{reviewed_skill_select_clause} AS reviewed_skill, review_skills.id as skill_id, review_skills.effectively_reviewed_times")
    .joins(:review_skills)
    .where(['review_skills.id IN (?)', review_skill_ids])
    
  end
    
  def points_for_review_early(number_of_points)
    
    review_skill_ids = review_skills                      
                      .where(["reviews.is_active = ?", true])
                      .where(["review_skills.last_reviewed_date < ?", Date.today])
                      .order('review_skills.review_due_date ASC')
                      .limit(number_of_points).map(&:id)
    
    Point.select("points.*, #{reviewed_skill_select_clause} AS reviewed_skill, review_skills.id AS skill_id")
    .joins(:review_skills)
    .where(['review_skills.id IN (?)', review_skill_ids])
    
  end
  
  def load_points_by_skills(skills)
    
    condition = skills.map{|point_id, skill_symbol| "(reviews.point_id = #{point_id.to_i} AND review_skills.skill = #{ReviewSkill::SKILLS[skill_symbol.to_sym]})" }.join(' OR ')
    
    review_skill_ids = review_skills.where([condition]).map(&:id)
    
    Point.select("points.*, #{reviewed_skill_select_clause} AS reviewed_skill, review_skills.id AS skill_id")
    .joins(:review_skills)
    .where(['review_skills.id IN (?)', review_skill_ids])    
    .sort_by{|point| skills.index{|sk| sk[0] == point.id && sk[1] == point.reviewed_skill} }
    
  end
  
  def new_points_to_learn(number_of_points = 10)
    
    current_lesson.reload #this line is here to prevent a strange error (current_lesson contains only id and position attributes)
    
    current_syllabus = current_lesson.syllabus
    
    Point
    .joins(lesson: :syllabus)
    .joins("LEFT OUTER JOIN reviews ON reviews.point_id = points.id AND reviews.user_id = #{self.id}")
    .where(['reviews.point_id IS NULL']) #excludes points already be in user's bag
    .where(['syllabuses.syllabus_order > ? OR (syllabuses.syllabus_order = ? AND lessons.position >= ?)',
            current_syllabus.syllabus_order,
            current_syllabus.syllabus_order,
            current_lesson.position
          ])
    .where(['lessons.active = ?', true])
    .where(['points.is_valid = ? OR points.is_supporting = ?', true, true])
    .where(['points.is_private = ?', false])
    .order('syllabuses.syllabus_order ASC, lessons.position ASC, points.position ASC')
    .limit(number_of_points)
    
  end  
    
  def password=(passwd)
    @password = passwd || ''
    self.salt = generate_salt if new_record?
    self.hashed_password = encrypt_password(@password, salt) if !passwd.blank?
  end
  
  def recovering_password=(passwd)
    @recovering_password = passwd || ''    
    self.hashed_recovering_password = encrypt_password(@recovering_password, salt) if !passwd.blank?
  end  
    
  def set_recovering_password(passwd)
    self.recovering_password = passwd
    self.save!(validate: false)
  end    
  
  def has_password?(passwd)
    hashed_password == encrypt_password(passwd, self.salt)
  end
  
  def has_recovering_password?(recovering_passwd)
    hashed_recovering_password == encrypt_password(recovering_passwd, self.salt)
  end
    
  def is_status?(status_key)
    self.status == STATUSES.fetch(status_key)
  end
  
  def confirm_registration(hash)
    if confirmation_hash_valid?(hash)
      activate
      add_as_friend_of_inviter
      true
    else
      false
    end
  end
  
  def activate
    update_attribute :status, STATUSES.fetch(:active)
  end    
  
  def put_points_to_bag(learning_data)
    
    old_level = self.level
    
    added_score, valid_ids = find_valid_points_and_put_to_bag(learning_data)
    
    opportunity = ExceptionHandler.ignore{ ReviewSummary.update_review_summary_for_user(self.id, valid_ids.count) }
    
    action = UserReviewPointAction.create(
                                            user_id: self.id,
                                            data:{
                                                old_level_id: old_level.id,
                                                new_level_id: self.level.id,
                                                score_change: added_score,
                                                number_of_reviewed_items: valid_ids.count
                                              }
                                          )
    
    {
      score_change: added_score,
      level_changed: self.level.highest_score <=> old_level.highest_score,
      overcome_friends: action.overcome_friends.map(&:name),
      action_id: action.id,
      opportunity: opportunity,
      number_of_rewarded_lucky_stars: Badge.toss_lucky_stars_to_user(self.id)
    }
    
  end
    
  def top_friends(max=10)    
    ids = friends.select('users.id').map(&:id).push(self.id)
    User.includes(:level).best_studying.with_ids(ids).limit(max)
  end
  
  def send_invitations_to(emails)
       
    existing_members  = User.select('id, email').where(['email IN (?)', emails])
         
    add_users_as_friends existing_members
        
    create_invitations_to_emails( emails - existing_members.map(&:email) )
    
  end
  
  def pick_out_emails_of_friends(emails)
    friends.select('email').map(&:email) & emails
  end
  
  def previous_active_lessons   
    Lesson.joins(:syllabus).where(['syllabuses.syllabus_order < ? OR (syllabuses.syllabus_order=? AND lessons.position <= ? )', current_syllabus_order, current_syllabus_order, current_lesson.position])
  end
  
  def calculate_score(point_ids = nil)
    
    return 0 if point_ids.instance_of?(Array) && point_ids.empty?
    
    query = review_skills
    
    if point_ids.instance_of?(Array) && point_ids.any?
      query = query.where(['reviews.point_id IN (?)', point_ids])
    end
    
    query.sum("IF(effectively_reviewed_times <= 10, effectively_reviewed_times, 10)")
    
  end
  
  def process_review(review_data)

    changed_skills = []
    action = nil
    old_level = self.level
    old_score = self.score
    linked_point_ids = []
    
    review_data.each do |skill_id, reminded_times, is_mastered|  
      
      review_skill = self.review_skills.find(skill_id) rescue nil
      
      if !review_skill.nil?
        
        review_skill.process_review(reminded_times.to_i, is_mastered)
        
        changed_skills.push review_skill
        
        #if review_skill.skill == ReviewSkill::SKILLS.fetch(:verbal)
        #  linked_point_ids += review_skill.review.point.main_example.linked_points.map(&:id) rescue []
        #end
        
      end
      
    end
    
    #if linked_point_ids.any?

    #  linked_skills = self.review_skills.where(["review_skills.skill = ?", ReviewSkill::SKILLS.fetch(:interpret)]).where(["reviews.point_id IN (?)", linked_point_ids])
      
    #  linked_skills.each do |review_skill|
    #    review_skill.process_review(0)
    #    changed_skills.push review_skill
    #  end
      
    #end
    
    changed_skills.map(&:save!)

    opportunity = ExceptionHandler.ignore{ ReviewSummary.update_review_summary_for_user(self.id, changed_skills.count) }
    
    self.score = calculate_score
    
    self.level = Level.get_level_for_score(self.score)
    
    save!(validate: false)
    
    score_change = self.score - old_score
    
    action = UserReviewPointAction.create(
                                            user_id: self.id,
                                            data:{
                                                old_level_id: old_level.id,
                                                new_level_id: self.level.id,
                                                score_change: score_change,
                                                number_of_reviewed_items: review_data.length
                                              }
                                          )
    
    {
      score_change: score_change,
      level_changed: self.level.highest_score <=> old_level.highest_score,
      overcome_friends: action.overcome_friends.map(&:name),
      action_id: action.id,
      opportunity: opportunity,
      number_of_rewarded_lucky_stars: Badge.toss_lucky_stars_to_user(self.id)
    }
    
  end
  
  def name
    (if middle_name.present? then middle_name + ' ' + first_name else last_name + ' ' + first_name end).squeeze(' ')
  end
    
  def today_reviewed_skills_exist?(skills)
    condition = skills.map{|point_id, skill_symbol| "(reviews.point_id = #{point_id.to_i} AND review_skills.skill = #{ReviewSkill::SKILLS.fetch(skill_symbol.to_sym)})" }.join(' OR ')
    review_skills.where([condition]).where(['review_skills.last_reviewed_date = ?', Date.today]).any?
  end
    
  def friend_add(other_user)
    add_user_as_a_friend(other_user)
  end
  
  def friend_with?(other_user)
    friends.where(:id => other_user.id).any?
  end
  
  def unfriend(other_user)
    transaction do
      friendships.where(friend_id: other_user.id).destroy_all
      inverse_friendships.where(user_id: other_user.id).destroy_all
    end
  end
  
  def number_of_due_points
    review_skills
    .due
    .where(['reviews.is_active = ?', true])    
    .select(" COUNT(DISTINCT reviews.point_id) AS count ").first.count
  end
    
  private
    
  def find_valid_points_and_put_to_bag(learning_data)
    
    built_reviews = []
    
    point_ids = learning_data.map{|item| item[:point_id] }.uniq
    
    valid_points = Point.joins("LEFT OUTER JOIN reviews ON points.id = reviews.point_id AND reviews.user_id = #{self.id}")
    .where(['reviews.point_id IS NULL'])
    .where(id: point_ids)
    .where(is_private: false)
    .where(['is_valid = ? OR is_supporting = ?', true, true])
    
    valid_ids = valid_points.map(&:id)
      
    valid_points.each do |point|
      review = Review.new user_id: self.id, point_id: point.id, is_active: true
      built_reviews.push review
    end
    
    Review.import built_reviews
    
    review_skills = self.reviews.includes(:point).where(point_id: point_ids).map { |review|
      mastered_skill_symbols = learning_data.map{|item| review.point_id == item[:point_id] && item[:is_mastered] ? item[:skill_symbol].to_sym : nil}.compact
      no_reminded_skill_symbols = learning_data.map{|item| review.point_id == item[:point_id] && item[:reminded_times] == 0 ? item[:skill_symbol].to_sym : nil}.compact
      ReviewSkill.build_skills_for_review(review, mastered_skill_symbols, no_reminded_skill_symbols)      
    }.flatten
    
    ReviewSkill.import( review_skills )
        
    added_score = calculate_score(valid_ids)
    
    self.score = self.score + added_score
    
    self.level = Level.get_level_for_score(self.score)
    
    self.current_lesson = Point.find_highest_lesson_in_points(valid_ids) || self.current_lesson
    
    save!(validate: false)
    
    [added_score, valid_ids]
    
  end
  
  def current_syllabus_order
    current_lesson.syllabus.syllabus_order
  end
  
  def current_lesson_position(args)
    current_lesson
  end
  
  def create_invitations_to_emails(emails)
    invitations.create(emails.map {|email| {:receiver_email => email} })
  end
  
  def add_users_as_friends(users)
    existing_friend_ids = friendships.map(&:friend_id)
    new_friends         = users.select{|user| ! existing_friend_ids.include?(user.id) }
    new_friends.each do |new_friend|
      add_user_as_a_friend(new_friend)
    end
  end
  
  def add_user_as_a_friend(other_user)
    if ! friend_with?(other_user)
      transaction do
        inverse_friends << other_user
        friends << other_user
      end
    end
  end
  
  def add_as_friend_of_inviter
    inviter = Invitation.find_inviter_for_user(self)    
    if not inviter.nil?    
      add_user_as_a_friend(inviter)
    end
  end
    
  def confirmation_hash_valid?(hash)
    confirmation_hash == hash
  end  
  
  def create_confirmation_hash    
    self.confirmation_hash = Digest::SHA1.hexdigest(email+hashed_password)    
  end
    
  def generate_salt    
    seeds =  [(0..9),('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    (0..15).map{ seeds[rand(seeds.length)]  }.join          
  end
  
  def encrypt_password(passwd, salt)
    Digest::SHA1.hexdigest(passwd+"_"+salt)
  end
    
  def initialize_level    
    self.level = Level.order('highest_score ASC').first
  end
  
  def initialize_current_lesson
    self.current_lesson = Lesson.first
  end  
  
  def points_of_current_lesson_added?
    ! self.user_points.select('id').where(["point_id IN (?)", current_lesson.points.map(&:id)]).first.nil?
  end
  
  def reviewed_skill_select_clause
    "CASE " + ReviewSkill::SKILLS.map{|key, value| " WHEN review_skills.skill = #{value} THEN '#{key}' "}.join('') + " END"
  end
  
end

class << User
  
  def generate_password
    ( ('a'..'z').to_a.sample(3) + (0..9).to_a.sample(3) ).join('')
  end
  
  def authenticate(email, passwd)    
    user = where(' email = ? ', email).first
    return user if !user.nil? && user.has_password?(passwd)
    nil
  end

  def authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
  def has_recovering_password?(email, passwd)
    user = User.find_by(email: email)
    return !user.nil? && user.has_recovering_password?(passwd)
  end
  
  def authenticate_by_recovering_password(email, passwd)
    user = User.find_by(email: email)
    if !user.nil? && user.has_recovering_password?(passwd)
      user.update_attribute :password, passwd
      return user
    end
  end
  
end