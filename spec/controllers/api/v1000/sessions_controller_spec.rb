require 'spec_helper'

describe Api::V1000::SessionsController do
  
  describe "POST create_anonymous" do
    
    before :each do
      post :create_anonymous
    end
    
    it {should respond_with 200}
    
    it "creates an anonymous authentication token" do
      
      auth_token = AuthenticationToken.first
      expect(auth_token).not_to be nil
      expect(auth_token.user_type).to eq 'anonymous'
      expect(auth_token.user_id).to be nil
      
    end
     
  end
  
  describe "POST #create" do

    before(:each) do
      @user = FactoryBot.create :user, password: 'right_password'
    end

    context "the credentials are correct" do
      
      it "returns the user record and the encryped token" do
        
        post :create, { user: { email: @user.email, password: "right_password" } }
        
        should respond_with 200
        
        user = json_response
        
        expect(user.id).to be @user.id
        expect(user.first_name).to eq @user.first_name
        expect(user.last_name).to eq @user.last_name
        
        auth_token = AuthenticationToken.first
        expect(auth_token.user_id).to be @user.id
        expect(user.auth_token).to eq AuthenticationToken.send(:encrypt, auth_token.token)
        
      end
  
      it "activates user if user has not been activated" do
        
        @user.update_attributes status: User::STATUSES.fetch(:not_confirmed), password: nil
        
        post :create, { user: { email: @user.email, password: "right_password" } }
        
        expect(@user.reload.status).to be User::STATUSES.fetch(:active)
        
      end
      
      it "accepts recorvering password" do
        
        recovering_password = 'recovering_pass'
        
        @user.set_recovering_password(recovering_password)
        
        post :create, { user: { email: @user.email, password: recovering_password } }
        
        user = json_response
        
        expect(user.id).to be @user.id
        expect(AuthenticationToken.first.user_id).to be @user.id
        
      end
      
    end

    context "the credentials are incorrect" do

      before(:each) do
        post :create, { user: { email: @user.email, password: "wrong_password" } }
      end

      it "returns a json with an error message" do
        
        should respond_with 422
        
        expect(json_response.message).not_to be nil
        
      end
      
    end
    
    context "when user name or password is not provided" do
      
      it "returns an error message if password is not provided" do
        post :create, { user: { email: @user.email, password: "" } }
        expect(json_response.message).not_to be nil
        should respond_with 422
      end

      it "returns an error message if email is not provided" do
        post :create, { user: { email: "", password: "right_password" } }
        expect(json_response.message).not_to be nil
        should respond_with 422
      end
      
    end
    
    context "an anonymous token is passed with the request" do
      
      it "converts the anonymous token to a normal token and uses it" do
        
        encrypted_anonymous_token = AuthenticationToken.create_for_user(User.new)
        auth_token = AuthenticationToken.first
        
        request.headers["AUTH-USER-ID"] = nil
        request.headers["AUTH-TOKEN"] = encrypted_anonymous_token
        post :create, { user: { email: @user.email, password: "right_password" } }
        
        auth_token.reload
        expect(auth_token.user_id).to be @user.id
        expect(json_response.auth_token).to eq encrypted_anonymous_token
        
      end
      
    end
    
  end
  
  describe "POST #authenticate_by_token" do
    
    before :each do
      @user = User.one
      @auth_token = sign_in(@user)
    end
    
    context "the token is valid" do
      
      it "returns the user with the token" do
        
        post :authenticate_by_token, user: {user_id: @user.id, auth_token: @auth_token}
        
        should respond_with 200
          
        user = json_response
        expect(user.id).to be @user.id
        expect(user.first_name).to eq @user.first_name
        expect(user.last_name).to eq @user.last_name
        expect(AuthenticationToken.first.user_id).to be @user.id
        
      end
    
    end
    
    context "the token is invalid" do
      
      it "returns unauthorized status code" do
        
        post :authenticate_by_token, user: {user_id: @user.id, auth_token: "wrong_token"}
        
        should respond_with 401
          
        expect(json_response.message).not_to be nil
        
      end
      
    end
    
    context "the user_id is wrong" do
      
      it "returns unauthorized status code" do
        
        post :authenticate_by_token, user: {user_id: -1, auth_token: @auth_token}
        
        should respond_with 401
          
        expect(json_response.message).not_to be nil
        
      end
      
    end
    
    context "the token is anonymous" do
      
      it "returns unauthorized status code" do
        
        AuthenticationToken.update_all user_id: nil
        
        post :authenticate_by_token, user: {user_id: nil, auth_token: @auth_token}
          
        should respond_with 401
            
        expect(json_response.message).not_to be nil
        
      end
        
    end
    
    context "the token is inactive" do
      
      it "returns unauthorized status code" do
        
        AuthenticationToken.update_all is_active: false
        
        post :authenticate_by_token, user: {user_id: @user.id, auth_token: @auth_token}
          
        should respond_with 401
            
        expect(json_response.message).not_to be nil
        
      end
        
    end
    
  end
  
  describe "DELETE #destroy" do

    before(:each) do
      @user = FactoryBot.create :user
      @token = sign_in(@user)
      delete :destroy, id: @token
    end
    
    it "deactive the authentication token" do
      expect(AuthenticationToken.first.is_active).to be false
      should respond_with 204
    end

  end

end