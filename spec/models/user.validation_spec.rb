#encoding: utf-8

require_relative '../spec_helper'

describe User do
  
  subject {FactoryBot.build :user}
                             
  it 'should create a new instance given valid attributes' do
    FactoryBot.create(:user)
  end
         
  describe 'email' do
    
    it { is_expected.to validate_presence_of(:email) }
    
    it 'should accept valid emails' do
      for valid_email in %w{  user@foo.com  THE_USER@foo.bar.org  first.last@foo.jp  } do
        should allow_value( valid_email ).for(:email)  
      end
    end
    
    it 'should not accept invalid email' do
      for invalid_email in %w{  user@foo,com  user_at_foo.org  example.user@foo. } do
        should_not allow_value(invalid_email).for :email
      end
    end
    
    it 'should reject duplicate emails' do        
      FactoryBot.create(:user)
      should validate_uniqueness_of(:email).case_insensitive
    end
    
  end
          
  describe 'password' do
    
    it { is_expected.to validate_presence_of :password }
    
    it { should validate_length_of(:password).is_at_least(5).is_at_most(100) }
    
    it 'should accept ascii characters' do
      should allow_value('ABCDEFGHIJKLMNOPKRSTUVWXYZabcdefghijklmnopkrstuvwxyz0123456789!@#$%^&*()-_=+\\|[{]};:\'",<.>/?' ).for :password
    end
    
    it 'should reject non-ascii characters' do
      should_not allow_value('vĩđạica').for :password
    end
         
    it 'does not require password confirmation on create' do
      user = FactoryBot.build :user
      user.password_confirmation = 'wrong'
      expect(user).to be_valid
    end
    
    it 'requires password confirmaton on update' do       
      user = FactoryBot.create :user
      user.password_confirmation = 'wrong'
      expect(user).not_to be_valid
    end
          
    it 'should not require password on update' do
      user = FactoryBot.create :user
      user.password = nil
      expect(user).to be_valid
    end
    
  end
  
  describe 'gender' do
    
    it {  is_expected.to validate_presence_of(:gender).on(:update) }
    
    it {  should_not validate_presence_of(:gender).on(:create) }
    
    it {  should validate_inclusion_of(:gender).in_array User::GENDERS  }
    
  end
  
  describe 'first_name' do
          
    it { is_expected.to validate_presence_of(:first_name)}
    
  end
  
  describe 'last_name' do
          
    it { is_expected.to validate_presence_of(:last_name) }
    
  end
  
  describe 'image_of_beloved' do
    it { is_expected.to validate_presence_of(:image_of_beloved).on(:image_of_beloved_uploader) }      
  end
  
  describe 'relationship_to_beloved' do
    it { is_expected.to validate_presence_of(:relationship_to_beloved).on(:image_of_beloved_uploader) }      
  end
  
  it { should have_db_index :email }
  
  describe 'user_type' do
    it { should validate_inclusion_of(:user_type).in_array User::USER_TYPES }
  end
  
end