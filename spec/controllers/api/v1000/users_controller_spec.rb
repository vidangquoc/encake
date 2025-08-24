require 'spec_helper'

describe Api::V1000::UsersController do
  
  describe "GET profile" do

    before(:each) do
      @user = FactoryBot.create :user
      sign_in(@user)
      get :profile, format: :json
    end

    it { should respond_with 200 }

    it "returns the neccessary information of the authenticated user" do
      user_response = json_response
      expect(user_response.id).to eq @user.id
      expect(user_response.email).to eql @user.email
      expect(user_response.first_name).to eq @user.first_name
      expect(user_response.middle_name).to eq @user.middle_name
      expect(user_response.last_name).to eq @user.last_name
      expect(user_response.gender).to eq @user.gender
    end

  end

  describe "PUT update_avatar" do

    before(:each) do
      @user = FactoryBot.create :user
      @user.remove_avatar
      sign_in(@user)
    end

    context "valid files" do
      before :each do
        avatar = ActionDispatch::Http::UploadedFile.new({
          :filename => 'handsome_man.jpg',
          :type => 'image/jpeg',
          :tempfile => File.new("#{Rails.root}/spec/factories/sample_images/handsome_man.jpg")
        })
  
        put :update_avatar, avatar: avatar, format: :json
      end

      it { should respond_with 200 }
      
      it "updates the avatar" do
        @user.reload
        expect(@user.avatar.file.present?).to be true
        expect(json_response.message).not_to be nil
        expect(json_response.avatar.url).not_to be nil
        expect(json_response.avatar.thumb.url).not_to be nil
      end

    end

    context "invalid files" do
      before :each do
        avatar = ActionDispatch::Http::UploadedFile.new({
          :filename => 'beautiful.html',
          :type => 'text/html',
          :tempfile => File.new("#{Rails.root}/spec/factories/sample_files/beautiful.html")
        })
  
        put :update_avatar, avatar: avatar, format: :json
      end

      it { should respond_with 422 }
      
      it "does not update the avatar" do
        @user.reload
        expect(@user.avatar.file).to be nil
      end
    end

  end
  
  describe "POST create" do
    
    before :each do
      @user_data = {email: "example@example.com", first_name: 'John', last_name: 'Dave'}
    end
    
    context "all neccessary information is valid" do
      
      it "returns ok status code" do
        
        post :create, user: @user_data
        
        should respond_with 200
        
      end
      
      it "creates a new user" do
        
        post :create, user: @user_data
        
        new_user = User.first
        expect(new_user).not_to be nil
        expect(new_user.email).to eq "example@example.com"
        expect(new_user.first_name).to eq "John"
        expect(new_user.last_name).to eq "Dave"
        expect(new_user.status).to eq User::STATUSES.fetch(:not_confirmed)
        
      end
      
      it "sends out confirmation email" do
        expect{post :create, user: @user_data}.to change{ ActionMailer::Base.deliveries.count }.by(1)
      end
      
      it "creates an authentication token with 'registered' as user_type" do
        post :create, user: @user_data
        expect(AuthenticationToken.count).to be 1
      end
      
      context "an anonymous token is passed with the request" do
      
        it "destroys the anonymous token" do
          
          encrypted_anonymous_token = AuthenticationToken.create_for_user(User.new)
          auth_token = AuthenticationToken.first
          
          request.headers["AUTH-USER-ID"] = nil
          request.headers["AUTH-TOKEN"] = encrypted_anonymous_token
          
          post :create, user: @user_data
          
          expect(AuthenticationToken.find_by token: auth_token.token).to be nil
  
        end
        
      end
      
    end
    
    context "not all neccessary information is valid" do
      
      it "complains if email is not provided" do
        
        post :create, user: @user_data.merge(email: '')
        
        should respond_with 422
        
        expect(json_response.email).to include validation_error_on('user.email.blank')
        
      end
      
      it "complains if email does not have right format" do
        
        post :create, user: @user_data.merge(email: 'wrong_format@example')
        
        should respond_with 422
                
        expect(json_response.email).to include validation_error_on('user.email.invalid')
        
      end
      
      it "complains if email has been registered" do
        
        FactoryBot.create :user, email: 'taken@example.com'
        
        post :create, user: @user_data.merge(email: 'taken@example.com')
        
        should respond_with 422
                
        expect(json_response.email).to include validation_error_on('user.email.taken')
        
      end
      
      it "complains if first name is not provided" do
        
        post :create, user: @user_data.merge(first_name: '')
        
        should respond_with 422
        
        expect(json_response.first_name).to include validation_error_on('user.first_name.blank')
        
      end
      
      it "complains if last name is not provided" do
        
        post :create, user: @user_data.merge(last_name: '')
        
        should respond_with 422
        
        expect(json_response.last_name).to include validation_error_on('user.last_name.blank')
        
      end
      
    end
    
  end
  
  describe "PUT profile" do
    
    before :each do
        
      @user_data = {email: "example@example.com", first_name: 'John', last_name: 'Dave'}
      
      @user = FactoryBot.create :user, @user_data
      
      sign_in @user
      
      @updated_user_data = {
        first_name: 'Joe',
        last_name: 'Brown',
        middle_name: 'Mid',
        password: 'new_password',
        password_confirmation: 'new_password',
        gender: 'male'
      }
      
    end
    
    context "all information is valid" do
            
      it "returns ok status code" do
        
        put :profile, user: @updated_user_data
        
        should respond_with 200
        
      end
      
      it "updates user information" do
        
        put :profile, user: @updated_user_data
        
        should respond_with 200
        
        @user.reload
        expect(@user.first_name).to eq @updated_user_data[:first_name]
        expect(@user.last_name).to eq @updated_user_data[:last_name]
        expect(@user.middle_name).to eq @updated_user_data[:middle_name]
        expect(@user.has_password?(@updated_user_data[:password])).to be true
        expect(@user.gender).to eq @updated_user_data[:gender]
        
      end

      it "does not require new password" do
        
        put :profile, user: @updated_user_data.merge(password: '', password_confirmation: '')
        
        should respond_with 200
        
      end
      
      it "does not require middle name" do
        
        put :profile, user: @updated_user_data.merge(middle_name: '')
        
        should respond_with 200
        
      end
      
      it "does not allow email to be changed" do
        
        put :profile, user: @updated_user_data.merge(email: 'new_mail@example.com')
        
        should respond_with 200
        
        expect(@user.reload.email).to eq @user_data[:email]
        
      end
      
    end
    
    describe "not all user information is valid" do
      
      it "complains if first name is not provided" do
        
        put :profile, user: @updated_user_data.merge(first_name: '')
        
        should respond_with 422
        
        expect(json_response.first_name).to include validation_error_on('user.first_name.blank')
        
      end
      
      it "complains if last name is not provided" do
        
        put :profile, user: @updated_user_data.merge(last_name: '')
        
        should respond_with 422
        
        expect(json_response.last_name).to include validation_error_on('user.last_name.blank')
        
      end
      
      it "complains if new password is less than 5 characters in length" do
        
        put :profile, user: @updated_user_data.merge(password: 4.times.map{'a'}.join())
        
        should respond_with 422
        
        expect(json_response.password).to include validation_error_on('user.password.too_short').sub(/\%\{count\}/, '5')
        
      end
      
      it "complains if new password is more than 100 characters in length" do
        
        put :profile, user: @updated_user_data.merge(password: 101.times.map{'a'}.join())
        
        should respond_with 422
        
        expect(json_response.password).to include validation_error_on('user.password.too_long').sub(/\%\{count\}/, '100')
        
      end
      
      it "complains if new password contains invalid characters" do
        
        put :profile, user: @updated_user_data.merge(password: 'new_password à')
        
        should respond_with 422
        
        expect(json_response.password).to include validation_error_on('user.password.invalid')
        
      end
      
      it "complains if password confirmation does not match" do
        
        put :profile, user: @updated_user_data.merge(password: 'new_password', password_confirmation: 'wrong')
        
        should respond_with 422
        
        expect(json_response.password_confirmation).to include validation_error_on('user.password_confirmation.confirmation')
        
      end
      
      it "complains if gender is not provided" do
        
        put :profile, user: @updated_user_data.merge(gender: '')
        
        should respond_with 422
        
        expect(json_response.gender).to include validation_error_on('user.gender.blank')
        
      end
      
    end
    
  end
  
  describe "PUT recover_password" do
    
    context "invalid cases" do
    
      it "complains if an email is not provided" do
        
        put :recover_password, email: ''
        
        should respond_with 422
        
        expect(json_response.message).to eq I18n.t('users.recover_password.email_required')
        
      end
      
      it "complains if there is no user that has the provided email" do
        
        put :recover_password, email: 'non_existing@example.com'
        
        should respond_with 422
        
        expect(json_response.message).to eq I18n.t('users.recover_password.non_existing_account')
        
      end
      
    end
    
    context "an email with corresponding account is provided" do
      
      before :each do
        @user = FactoryBot.create :user
      end
      
      it "returns ok status code" do
        put :recover_password, email: @user.email
        should respond_with 200
      end
      
      it "sets recovering password for the corresponding user account" do
        put :recover_password, email: @user.email
        expect(@user.reload.hashed_recovering_password).not_to be nil
        expect(json_response.message).to eq I18n.t('users.recover_password.recovering_password_sent')
      end
    
      it "sends recovering password to the email address" do
        
        expect{put :recover_password, email: @user.email}.to change{ ActionMailer::Base.deliveries.count }.by(1)
                
      end
      
    end
    
  end
  
  describe "GET friends" do
    
    before :each do
      
      5.Level
      4.Users
      
      @user, @friend1, @friend2, @friend3 = User.first, User.third, User.fourth, User.second
      
      @user.update_attributes score: 40, level: Level.third
      @friend1.update_attributes score: 30, level: Level.third
      @friend2.update_attributes score: 20, level: Level.second
      @friend3.update_attributes score: 10, level: Level.first
                              
      @user.has_friendships([{friend_id: @friend1.id}, {friend_id: @friend2.id}, {friend_id: @friend3.id}])
      
      sign_in @user
      
    end
    
    it "returns ok status" do
      get :friends
      should respond_with 200
    end
    
    it "orders user and friends according to score" do
      
      get :friends
      
      expect(json_response.map(&:id)).to eq [@user, @friend1, @friend2, @friend3].map(&:id)
      
    end
    
    it 'does not include non-friend users' do
      
      @not_a_friend = User.one
      @not_a_friend.update_attribute :score, 40
      
      get :friends
      
      expect(json_response.map(&:id).include?(@not_a_friend.id)).to be false
      
    end
    
    it "returns necessary information" do
      
      get :friends
      
      friend = json_response.first
      
      expect(friend.id).not_to be nil
      expect(friend.first_name).not_to be nil
      expect(friend.middle_name).not_to be nil
      expect(friend.last_name).not_to be nil
      expect(friend.score).not_to be nil
      expect(friend.level.position).not_to be nil
      #expect(friend.avatar.url).not_to be nil
      #expect(friend.avatar.thumb.url).not_to be nil
      
    end
    
  end
  
  describe "POST add_point_to_bag" do
    
    it "adds point to user's point bag" do
      
      @point = FactoryBot.create :point
      @user = FactoryBot.create :user
      sign_in @user
      
      post :add_point_to_bag, point_id: @point.id
      
      should respond_with 200
      
      expect(@user.reviews.map(&:point_id)).to include @point.id
      
      expect(json_response.message).to eq I18n.t('users.add_point_to_bag.added')
    
    end
  
  end
  
  describe "PUT deactivate_point_in_bag" do
    
    it "deactives the corresponding review record in user's bag" do
    
      @point = FactoryBot.create :point
      @user = FactoryBot.create :user
      Point.add_point_for_user(@point.id, @user.id)
      
      sign_in @user
        
      post :deactivate_point_in_bag, point_id: @point.id
      
      should respond_with 200
      
      expect(@user.reviews.map(&:point_id)).to include @point.id
      expect(@user.reviews.find_by(point_id: @point.id).is_active).to be false # <=
      expect(json_response.message).to eq I18n.t('users.deactivate_point_in_bag.deactivated')
      
    end
    
  end
  
end