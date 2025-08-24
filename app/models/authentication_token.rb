class AuthenticationToken < ActiveRecord::Base
  
  self.primary_key = 'token'
  
  belongs_to :user
  
  validates :token, {
    :presence => true,
    :uniqueness => true
  }
  
  validates :user_type, {
    :presence => true,
    :inclusion => {:in => ["anonymous", "active", "just_registered"]}
  }
  
  def renew
    if updated_at <= 10.minutes.ago
      copy
      update_attributes created_at: DateTime.now, updated_at: DateTime.now
    else
      update_attribute :updated_at, DateTime.now
    end
  end
  
  def copy(attributes = {})
    
    copy_auth = self.dup
    
    copy_auth.attributes = {
      token: self.class.generate_unique_token,
      is_active: false,
      created_at: self.created_at,
      updated_at: self.updated_at
    }.merge(attributes)
    
    copy_auth.save
    
  end

end

class << AuthenticationToken
  
  def create_for_user(user, params = {})
    
    created = false
    token = 0
    user_type = user.new_record? ? 'anonymous' : 'active'
    
    while ! created
      
      auth = AuthenticationToken.new({user: user, user_type: user_type, token: generate_unique_token}.merge(params))
      
      if auth.save
        created = true
      end
      
    end
    
    encrypt(auth.token)
    
  end
  
  def find_active(user_id, encrypted_token)
    find_by(user_id: user_id, token: decrypt(encrypted_token), is_active: true)
  end
  
  def find_by_encrypted_token(encrypted_token)
    find_by(token: decrypt(encrypted_token))
  end
  
  def deactivate(use_id, encrypted_token)
    token = find_active(use_id, encrypted_token)
    token.update_attribute :is_active, false if token
  end
  
  def generate_unique_token
    token = generate_random_token
    while where(token: token).any?
      token = generate_random_token
    end
    token
  end
  
  private
  
  def generate_random_token
    rand(100000000000000)
  end
  
  def encrypt(token)
    token.to_s
  end
  
  def decrypt(encrypted_token)
    encrypted_token.to_i
  end
  
end
