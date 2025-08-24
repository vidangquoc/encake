require 'spec_helper'

RSpec.describe AuthenticationToken, type: :model do
  
  describe 'validations' do
    
    subject do
      FactoryBot.create(:authentication_token)
    end
    
    it { is_expected.to validate_presence_of :token }
    
    it { is_expected.to validate_uniqueness_of :token }
    
    it { is_expected.to validate_presence_of :user_type }
    
    it { is_expected.to validate_inclusion_of(:user_type).in_array(['anonymous', 'active', 'just_registered']) }
       
  end
  
  describe 'methods' do
    
    describe 'renew' do
      
      context "the authentication token has been idle for less than 10 minutes" do
      
        it "updates 'updated_at' attribute" do
          auth_token = AuthenticationToken.one
          auth_token.update_attribute :updated_at, 9.99.minute.ago
          old_created_at = auth_token.updated_at
          auth_token.renew
          expect(auth_token.updated_at).to be > old_created_at
        end
        
      end
      
      context "the authentication token has been idle for more than 10 minutes" do
        
        before :each do
          @created_at = 60.minutes.ago
          @updated_at = 10.minutes.ago
          @auth_token = AuthenticationToken.one
          @auth_token.update_attributes created_at: @created_at, updated_at: @updated_at
        end
          
        it "duplicates the authentication record" do
          @auth_token.renew
          dup_auth_token = AuthenticationToken.where('token <> ?', @auth_token.id).first
          expect(dup_auth_token).not_to be nil
          expect(dup_auth_token.created_at.to_i).to eq @created_at.to_i
          expect(dup_auth_token.updated_at.to_i).to eq @updated_at.to_i
          expect(dup_auth_token.is_active).to eq false
        end
        
        it "resets created_at and updated attributes" do
          @auth_token.renew
          @auth_token.reload
          expect(@auth_token.created_at).to be > 2.second.ago
          expect(@auth_token.updated_at).to be > 2.second.ago
        end
        
      end
    
    end
    
    describe "Class#create_for_user" do
        
      before :each do
        @user = FactoryBot.create :user
      end
      
      it "creates an authentication token for the user" do
        
        AuthenticationToken.create_for_user(@user, {ip_address: '12.23.56.78'})
        
        auth_token = AuthenticationToken.first
        
        expect(auth_token).not_to be nil
        
        expect(auth_token.user_id).to be @user.id
        
        expect(auth_token.user_type).to eq 'active'
        
        expect(auth_token.ip_address).to eq '12.23.56.78'
        
      end
      
      it "returns the newly created token in encrypted form" do
        
        encrypted_token = AuthenticationToken.create_for_user(@user)
        
        expect(encrypted_token).to eq AuthenticationToken.send(:encrypt, AuthenticationToken.first.token)
        
      end
      
      it "creates an anonymous authentication token for anonymous user" do
        
        anonymous_user = User.new
        
        AuthenticationToken.create_for_user(anonymous_user)
        
        auth_token = AuthenticationToken.first
        
        expect(auth_token.user_id).to be nil
        
        expect(auth_token.user_type).to eq 'anonymous'
        
      end
      
    end
    
    describe "Class#find_active" do
      
      before :each do
        @user = FactoryBot.create :user
        2.AuthenticationToken
        @encrypted_token = AuthenticationToken.create_for_user(@user)
      end
      
      it "returns the found authetication token record" do
        auth_token = AuthenticationToken.find_active(@user.id, @encrypted_token)
        expect(auth_token.user_id).to eq @user.id
      end
      
      it "returns nil if no authentication token found" do
        expect(AuthenticationToken.find_active(@user.id, "wrong_token")).to be nil
      end
      
      it "ignores in_active token" do
        auth_token = AuthenticationToken.find_active(@user.id, @encrypted_token)
        auth_token.update_attribute :is_active, false
        expect(AuthenticationToken.find_active(@user.id, @encrypted_token)).to be nil
      end
      
    end
    
    describe "Class#deactivate" do
      
      it "deactivates the authentication token" do
        
        @user = FactoryBot.create :user
        encrypted_token1 = AuthenticationToken.create_for_user(@user)
        encrypted_token2 = AuthenticationToken.create_for_user(@user)
        
        AuthenticationToken.deactivate(@user.id, encrypted_token1)
        
        expect(AuthenticationToken.find_by(user_id: @user.id, token: AuthenticationToken.send(:decrypt, encrypted_token1)).is_active).to be false
        expect(AuthenticationToken.find_by(user_id: @user.id, token: AuthenticationToken.send(:decrypt, encrypted_token2)).is_active).to be true
        
      end
      
    end
    
    describe "copy" do
      
      it "copies the authentication record" do
        auth_token = AuthenticationToken.one
        auth_token.copy(user_type: 'just_registered')
        copy_token = AuthenticationToken.where(['token <> ?', auth_token.id]).first
        expect(copy_token).not_to be nil
        expect(copy_token.user_type).to eq 'just_registered'
        expect(copy_token.created_at.to_i).to eq auth_token.created_at.to_i
        expect(copy_token.updated_at.to_i).to eq auth_token.updated_at.to_i
        expect(copy_token.is_active).to eq false
      end
      
    end
    
    describe "Class#find_by_encrypted_token" do
      
      before :each do
        @encrypted_token = AuthenticationToken.create_for_user(User.one)
      end
      
      it "returns the auth token record" do
        
        auth_token = AuthenticationToken.find_by_encrypted_token(@encrypted_token)
        expect(auth_token).not_to be nil
        expect(auth_token.id).to be AuthenticationToken.first.id
        
      end
      
      it "returns nil if no record found" do
        
        auth_token = AuthenticationToken.find_by_encrypted_token("wrong_token")
        expect(auth_token).to be nil
        
      end
      
    end
      
  end
  
end
                                                         