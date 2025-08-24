class Administrator < ActiveRecord::Base  
  attr_accessor :password
  strip_attributes collapse_spaces: true
  
  EMAIL_FORMAT = /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  ROLES = {:super => 'Super', :moderator => 'Moderator'}
  
  validates :email, {
    :presence => true,
    :format => {:with => EMAIL_FORMAT },
    :uniqueness => {:case_sensitive => false}
  }
  
  validates :password, {
    :presence => true,
    :length => {:minimum => 5, :maximum => 100},
    :format => {:with =>/\A[\x00-\x7F]*\z/ },
    :confirmation => true,
    :if => ->{ self.new_record? or self.password.present? }
  }
  
  def password=(passwd)
    @password = passwd || ''
    self.salt = generate_salt if new_record?
    self.hashed_password = encrypt_password(@password, salt)
  end  
    
  def self.authenticate(username, submitted_password)    
    user = where(' email = ?', username).first
    return nil if user.nil?
    return user if user.has_password?(submitted_password)
  end

  def self.authenticate_with_salt(id, cookie_salt)
    user = find_by_id(id)
    (user && user.salt == cookie_salt) ? user : nil
  end
  
  def has_password?(passwd)
    hashed_password == encrypt_password(passwd, self.salt)
  end
  
  def super?
    self.role == 'super'
  end
  
  def moderator?
    self.role == 'moderator'
  end
  
  private
  
  def generate_salt    
    seeds =  [(0..9),('a'..'z'),('A'..'Z')].map{|i| i.to_a}.flatten
    (0..15).map{ seeds[rand(seeds.length)]  }.join          
  end
  
  def encrypt_password(passwd, salt)
    Digest::SHA1.hexdigest(passwd+"_"+salt)
  end
  
end
