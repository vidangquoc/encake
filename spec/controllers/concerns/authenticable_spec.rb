require 'spec_helper'

describe Authenticable do
  
  class Authentication
    include Authenticable
  end
  
  let(:authentication) { Authentication.new }
  subject { authentication }
  
  before :each do
    @user = FactoryBot.create :user
    allow(authentication).to receive(:request).and_return(request)
  end

  describe "#current_user" do
    
    before do
      @token = AuthenticationToken.create_for_user @user
      request.headers["AUTH-USER-ID"] = @user.id
      request.headers["AUTH-TOKEN"] = @token
    end
    
    it "returns the user from the authorization header" do
      expect(authentication.current_user.id).to eql @user.id
    end
    
    it "returns nil if the authentication header is wrong" do
      request.headers["AUTH-TOKEN"] = "wrong_token"
      expect(authentication.current_user).to be nil
    end
    
  end
  
  describe "#sign_in" do
    
    context "signing in a registered user" do
      
      context "no anonymous token is passed with the request" do
      
        before :each do
          @auth_token = authentication.sign_in(@user)
        end
        
        it "creates an authentication token for the user" do
          auth_token = AuthenticationToken.find_by(user_id: @user.id) 
          expect(auth_token).not_to be nil
          expect(auth_token.user_type).to eq 'active'
        end
        
        it "sets current user" do
          expect(authentication.current_user.id).to be @user.id
        end
        
        it "returns the newly created authentication token" do
          expect(AuthenticationToken.find_active(@user.id, @auth_token)).not_to be nil
        end
        
      end
        
      context "an anonymous token is passed with the request" do
      
        it "converts the anonymous token to a normal token and uses it" do
          
          encrypted_anonymous_token = AuthenticationToken.create_for_user(User.new)
          auth_token = AuthenticationToken.first
          
          request.headers["AUTH-USER-ID"] = nil
          request.headers["AUTH-TOKEN"] = encrypted_anonymous_token
          encrypted_token = authentication.sign_in @user
          
          auth_token.reload
          expect(auth_token.user_id).to be @user.id
          expect(auth_token.user_type).to eq 'active'
          expect(encrypted_token).to eq encrypted_anonymous_token
          
        end
        
      end
      
    end
    
    context "signing in an anonymous user" do
      
      before :each do
        @user = User.new #user does not exist in database
        @auth_token = authentication.sign_in(@user)
      end
      
      it "creates an anonymous authentication token" do
        auth_token = AuthenticationToken.first 
        expect(auth_token).not_to be nil
        expect(auth_token.user_type).to eq 'anonymous'
      end
      
      it "sets current user to nil" do
        expect(authentication.current_user.id).to be nil
      end
      
      it "returns the newly created authentication token" do
        expect(AuthenticationToken.find_active(@user.id, @auth_token)).not_to be nil
      end
      
    end
    
  end
  
  describe "#sign_out" do
    
    before :each do
      @auth_token = authentication.sign_in(@user)
      authentication.sign_out(@auth_token)
    end
    
    it "deactives the authetication token" do
      expect(AuthenticationToken.first.is_active).to be false
    end
    
    it "sets current user to nil" do
      expect(authentication.current_user).to be nil
    end
    
  end
  
end

describe Authenticable, type: :controller do

  controller(BaseController) do
    
    include Authenticable
    
    def authentication_test
      authenticate
      render json: {}, status: :ok
    end
    
    def raise_an_error
      raise "This is an error"
    end
    
  end
  
  before do
    routes.draw do
      get 'authentication_test' => 'base#authentication_test'
      get 'raise_an_error' => 'base#raise_an_error'
    end
  end
  
  describe "#authenticate" do
    
    context "with a normal authentication token" do
    
      before :each do
        @user = FactoryBot.create :user
        @token = AuthenticationToken.create_for_user @user
        @auth_token = AuthenticationToken.first
      end
      
      context "the authentication headers are not valid" do
      
        it "returns error status code if the token is wrong" do
          request.headers["AUTH-USER-ID"] = @user.id
          request.headers["AUTH-TOKEN"] = "wrong_token"
          get :authentication_test
          should respond_with 401 
          expect(json_response.message).to eql "Not authenticated!"
        end
        
        it "returns error status code if the token is not active" do
          request.headers["AUTH-USER-ID"] = @user.id
          request.headers["AUTH-TOKEN"] = @token
          AuthenticationToken.find_active(@user.id, @token).update_attribute :is_active, false
          get :authentication_test
          should respond_with 401 
          expect(json_response.message).to eql "Not authenticated!"
        end
        
      end
      
      context "the authentication headers are valid" do
        
        before :each do
          request.headers["AUTH-USER-ID"] = @user.id
          request.headers["AUTH-TOKEN"] = @token
        end
        
        it "lets the user in if the authentication header is correct" do
          get :authentication_test
          should respond_with 200
        end
        
        context "the authentication token has been idle for less than 10 minutes" do
                  
          it "updates 'updated_at' attribute of the authentication token record" do
            @auth_token.update_attribute :updated_at, 9.9.minutes.ago
            get :authentication_test
            expect(@auth_token.reload.updated_at).to be > 1.second.ago
          end
          
        end
        
        context "the authentication token has been idle for more than 10 minutes" do
          
          before :each do
            @created_at = 60.minutes.ago
            @updated_at = 10.minutes.ago
            @auth_token.update_attributes created_at: @created_at, updated_at: @updated_at
            get :authentication_test
          end
          
          it "copies the authentication record with a new key" do
            expect(AuthenticationToken.count).to be 2
            dup_auth_token = AuthenticationToken.where(['token <> ?', AuthenticationToken.send(:decrypt, @token)]).first
            expect(dup_auth_token).not_to be nil
            expect(dup_auth_token.created_at.to_i).to eq @created_at.to_i
            expect(dup_auth_token.updated_at.to_i).to eq @updated_at.to_i
            expect(dup_auth_token.is_active).to eq false
          end
          
          it "resets created_at and updated attributes" do
            @auth_token.reload
            expect(@auth_token.created_at).to be > 2.second.ago
            expect(@auth_token.updated_at).to be > 2.second.ago
          end
          
        end
        
      end
        
    end
  
    context "with an anonymous authentication token" do
    
      before :each do
        @user = User.new #anonymous user
        @token = AuthenticationToken.create_for_user(@user)
        @auth_token = AuthenticationToken.first
      end
      
      context "the authentication headers are not valid" do
      
        it "returns error message" do
          request.headers["AUTH-USER-ID"] = nil
          request.headers["AUTH-TOKEN"] = "wrong_token"
          get :authentication_test
          expect(json_response.message).to eql "Not authenticated!"
          should respond_with 401 
        end
        
      end
      
      context "the authentication headers are valid" do
        
        before :each do
          request.headers["AUTH-USER-ID"] = nil
          request.headers["AUTH-TOKEN"] = @token
        end
        
        it "returns error message" do
          get :authentication_test
          expect(json_response.message).to eql "Not authenticated!"
          should respond_with 401
        end
        
        context "the authentication token has been idle for less than 10 minutes" do
          
          it "updates 'updated_at' attribute of the authentication token record" do
            @auth_token.update_attribute :updated_at, 9.9.minutes.ago
            get :authentication_test
            expect(@auth_token.reload.updated_at).to be > 1.second.ago
          end
          
        end
        
        context "the authentication token has been idle for more than 10 minutes" do
          
          before :each do
            @created_at = 60.minutes.ago
            @updated_at = 10.minutes.ago
            @auth_token.update_attributes created_at: @created_at, updated_at: @updated_at
            get :authentication_test
          end
          
          it "copies the authentication record with a new key" do
            expect(AuthenticationToken.count).to be 2
            dup_auth_token = AuthenticationToken.where(['token <> ?', AuthenticationToken.send(:decrypt, @token)]).first
            expect(dup_auth_token).not_to be nil
            expect(dup_auth_token.created_at.to_i).to eq @created_at.to_i
            expect(dup_auth_token.updated_at.to_i).to eq @updated_at.to_i
            expect(dup_auth_token.is_active).to eq false
          end
          
          it "resets created_at and updated attributes" do
            @auth_token.reload
            expect(@auth_token.created_at).to be > 2.second.ago
            expect(@auth_token.updated_at).to be > 2.second.ago
          end
          
        end
        
      end
      
    end
    
  end
  
  describe "handle_error" do
    
    it "returns right status code" do
    
      sign_in User.one
    
      get :raise_an_error
    
      should respond_with 500
      
      expect(json_response.message).to eq "This is an error"
    
    end
    
  end
  
end
