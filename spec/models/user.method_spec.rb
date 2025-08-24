#encoding: utf-8

require_relative '../spec_helper'

describe User do    

  before :each do      
    @user = User.one
    @user.belongs_to Level.one
    @user.reload
  end
    
  describe 'points_for_review' do
    
    before :each do
      @user.has_10_reviews(:assoc).belongs_to(10.Points)
      Review.all.each do |review|
        review.has_review_skills(ReviewSkill::SKILLS.values.map{|skill| {skill: skill}})
      end
    end
    
    it 'gets the right number of reviewed skills' do
      @user.review_skills.update_all review_due_date: today
      expect(@user.points_for_review(5).to_a.count).to be 5
    end
        
    it 'does not get new points' do
      @user.review_skills.update_all review_due_date: DateTime.now.tomorrow.to_date
      3.Points
      expect(@user.points_for_review(5).to_a.count).to be 0
    end
    
    it 'does not get undue reviewed skills' do
      @user.review_skills.update_all review_due_date: DateTime.now.tomorrow.to_date
      expect(@user.points_for_review(5).to_a.count).to be 0
    end
    
    it 'does not get skills that parent reviews are inactive' do
      @user.review_skills.update_all review_due_date: DateTime.now.yesterday.to_date
      Review.update_all is_active: false
      expect(@user.points_for_review(5).to_a.count).to be 0
    end
    
    it "returns skill name instead of skill code" do
      @user.review_skills.update_all review_due_date: DateTime.now.yesterday.to_date
      expect(ReviewSkill::SKILLS.keys.map(&:to_s)).to include @user.points_for_review(5).first.reviewed_skill
    end
    
    it "returns skill id" do
      @user.review_skills.update_all review_due_date: DateTime.now.yesterday.to_date
      expect(@user.points_for_review(5).map(&:skill_id) - @user.review_skills.map(&:id)).to eq []
    end
    
  end
    
  describe 'points_for_review_early' do
    
    before :each do
            
      review1, review2, review3 = @user.has_3_reviews(:assoc).belongs_to(3.Points)
      
      data1 = [
        {:review_due_date => Date.today + 1.day, last_reviewed_date: Date.today - 1.day, skill: ReviewSkill::SKILLS.fetch(:interpret)},
        {:review_due_date => Date.today + 2.day, last_reviewed_date: Date.today, skill: ReviewSkill::SKILLS.fetch(:grammar)},
        {:review_due_date => Date.today + 3.day, last_reviewed_date: Date.today - 1.day, skill: ReviewSkill::SKILLS.fetch(:verbal)},
      ]
      
      data2 = [
        {:review_due_date => Date.today + 1.day, last_reviewed_date: Date.today - 1.day, skill: ReviewSkill::SKILLS.fetch(:interpret)},
        {:review_due_date => Date.today + 2.day, last_reviewed_date: Date.today - 1.day, skill: ReviewSkill::SKILLS.fetch(:grammar)},
        {:review_due_date => Date.today + 3.day, last_reviewed_date: Date.today - 1.day, skill: ReviewSkill::SKILLS.fetch(:verbal)},
      ]
      
      data3 = [
        {:review_due_date => Date.today + 1.day, last_reviewed_date: Date.today - 1.day, skill: ReviewSkill::SKILLS.fetch(:interpret)},
        {:review_due_date => Date.today + 2.day, last_reviewed_date: Date.today - 1.day, skill: ReviewSkill::SKILLS.fetch(:grammar)},
        {:review_due_date => Date.today + 3.day, last_reviewed_date: Date.today - 1.day, skill: ReviewSkill::SKILLS.fetch(:verbal)},
      ]
       
      @interpret1, @grammar1 = review1.has_review_skills(data1, :assoc).first(2)
      @interpret2, @grammar2 = review2.has_review_skills(data2, :assoc).first(2)
      @interpret3, @grammar3 = review3.has_review_skills(data3, :assoc).first(2)
      
    end
    
    it 'gets the right number of reviewed skills' do
      expect(@user.points_for_review_early(3).to_a.count).to be 3
    end
    
    it 'favors skills with smaller review_due_date' do
      expect(@user.points_for_review_early(3).map(&:skill_id).sort).to eq [@interpret1.id, @interpret2.id, @interpret3.id].sort
    end
    
    it 'excludes points that has already reviewed today' do
      @interpret1.update_attribute :last_reviewed_date, Date.today
      expect(@user.points_for_review_early(20).map(&:skill_id).sort).not_to include(@interpret1)
    end
    
    it 'does not get skills that parent reviews are inactive' do
      @user.review_skills.update_all review_due_date: DateTime.now.yesterday.to_date
      Review.update_all is_active: false
      expect(@user.points_for_review_early(5).to_a.count).to be 0
    end
    
    it "returns skill name instead of skill code" do
      @user.review_skills.update_all review_due_date: DateTime.now.yesterday.to_date + 2.days
      expect(ReviewSkill::SKILLS.keys.map(&:to_s)).to include @user.points_for_review_early(5).first.reviewed_skill
    end
    
    it "returns skill id" do
      @user.review_skills.update_all review_due_date: DateTime.now.yesterday.to_date + 2.days
      expect(@user.points_for_review_early(5).map(&:skill_id) - @user.review_skills.map(&:id)).to eq []
    end
        
  end
  
  describe 'number_of_due_points' do
    
    before :each do
      @user.has_5_reviews(:assoc).belongs_to(5.Points)
      Review.all.each do |review|
        review.has_review_skills(ReviewSkill::SKILLS.values.map{|skill| {skill: skill}})
      end
    end
    
    it "counts the number of reviews" do
      expect(@user.number_of_due_points).to be 5
    end
    
    it 'does not count inactive reviews' do
      @user.reviews.limit(2).update_all is_active: false
      expect(@user.number_of_due_points).to be 3
    end
    
    it 'includes reviews that have at least one due skill' do
      review = @user.reviews.first
      review.review_skills.update_all(review_due_date: Date.today + 10.day)
      spelling_skill = review.review_skills.sample
      spelling_skill.update_attribute :review_due_date, today
      expect(@user.number_of_due_points).to be 5
    end
    
    it 'excludes reviews that have no due skills' do
      review = @user.reviews.first
      review.review_skills.update_all(review_due_date: Date.today + 10.day)
      expect(@user.number_of_due_points).to be 4
    end
    
  end  
  
  describe 'load_points_by_skills' do
    
    before :each do
            
      @level1, @level2, @level3 = 3.Levels
      
      @user.update_attribute :level_id, @level1.id
      
      @point1, @point2 = 2.Points
      
      @review1, @review2 = @user.has_2_reviews(:assoc).belongs_to [@point1, @point2]
      
      @review1.has_review_skills([
        {skill: ReviewSkill::SKILLS.fetch(:interpret)},
        {skill: ReviewSkill::SKILLS.fetch(:grammar)},
        {skill: ReviewSkill::SKILLS.fetch(:verbal)},
      ], :assoc)
      
      @review2.has_review_skills([
        {skill: ReviewSkill::SKILLS.fetch(:interpret)},
        {skill: ReviewSkill::SKILLS.fetch(:grammar)},
        {skill: ReviewSkill::SKILLS.fetch(:verbal)},
      ], :assoc)
      
    end
    
    it 'loads the right skills' do
        
      points = @user.load_points_by_skills([[@point1.id, 'interpret'], [@point2.id, 'grammar']])
      
      expect(points.map{|point| [point.id, point.reviewed_skill]}).to eq [[@point1.id, 'interpret'], [@point2.id, 'grammar']]
      
    end
    
    it 'returns skills in the correct order' do
      
      points = @user.load_points_by_skills([[@point2.id, 'grammar'], [@point1.id, 'interpret']])
      
      expect(points.map{|point| [point.id, point.reviewed_skill]}).to eq [[@point2.id, 'grammar'], [@point1.id, 'interpret']]
      
    end
    
    it 'does not load skills of other users' do
      
      user2 = User.one
      
      user2.update_attribute :level_id, @level1.id
      
      review = user2.has_1_reviews(:assoc).belongs_to([@point1]).first
      
      review.has_review_skills([
        {skill: ReviewSkill::SKILLS.fetch(:interpret)},        
        {skill: ReviewSkill::SKILLS.fetch(:grammar)},
      ], :assoc)
      
      points = @user.load_points_by_skills([[@point1.id, 'interpret'], [@point2.id, 'grammar']])
      
      expect(points.map{|point| [point.id, point.reviewed_skill]}).to eq [[@point1.id, 'interpret'], [@point2.id, 'grammar']]      
      
    end
      
  end
  
  describe 'new_points_to_learn' do
    
    before :each do
      4.Lessons.belongs_to(2.Syllabus).each_has_10_points
      @user.belongs_to_current_lesson Lesson.second
    end
    
    it "gets new points from current lesson" do
      expect(@user.new_points_to_learn.map(&:id) - @user.current_lesson.points.map(&:id)).to eq []
    end
    
    it "returns the number of points correctly" do
      expect(@user.new_points_to_learn(5).count).to be 5
    end
    
    it "sorts the returned points according to their 'position'" do
      new_points_to_learn = @user.new_points_to_learn
      expect(new_points_to_learn.map(&:id)).to eq(new_points_to_learn.sort_by(&:position).map(&:id))
    end
    
    it "does not return points that has already been in user's point bag" do
      
      point1   = @user.current_lesson.points.sample
      point2 = @user.current_lesson.next_active.points.sample
      @user.has_reviews([{point_id: point1.id}, {point_id: point2.id}])
      new_points_to_learn_ids = @user.new_points_to_learn(1000).map(&:id)
      
      expect(new_points_to_learn_ids & [point1.id, point2.id]).to eq []
      
    end
    
    it "gets points from the next active lesson if the current lesson doesn't have enough points" do
      
      point_ids_in_current_lesson = @user.current_lesson.points.map(&:id)
      point_ids_in_next_active_lesson = @user.current_lesson.next_active.points.map(&:id)
      
      ids_of_new_points_to_learn = @user.new_points_to_learn(15).map(&:id)
      point_ids_chosen_from_next_active_lesson = ids_of_new_points_to_learn - point_ids_in_current_lesson

      expect(ids_of_new_points_to_learn.count).to be 15
      expect( (point_ids_chosen_from_next_active_lesson & point_ids_in_next_active_lesson).sort ).to eq point_ids_chosen_from_next_active_lesson
      
    end
    
    it "does not get points from unactive lessons" do
      
      next_lesson = @user.current_lesson.next_active
      next_lesson.update_attribute :active, false
      ids_of_new_points_to_learn = @user.new_points_to_learn(15).map(&:id)
      
      expect(ids_of_new_points_to_learn.count).to be 15
      expect(ids_of_new_points_to_learn & next_lesson.points.map(&:id)).to eq []
      
    end
    
    it "does not get points that are invalid and are not supporting" do
      
      invalid_point = @user.current_lesson.points.sample
      invalid_point.update_attributes is_valid: false, is_supporting: false
      ids_of_new_points_to_learn = @user.new_points_to_learn(100).map(&:id)
      
      expect(ids_of_new_points_to_learn).not_to include(invalid_point.id)
      
    end
    
    it "gets valid or supporting points" do
      
      valid_point, supporting_point = @user.current_lesson.points.sample(2)
      valid_point.update_attributes is_valid: true, is_supporting: false
      supporting_point.update_attributes is_valid: false, is_supporting: true
      ids_of_new_points_to_learn = @user.new_points_to_learn(100).map(&:id)
      
      expect(ids_of_new_points_to_learn).to include(valid_point.id)
      expect(ids_of_new_points_to_learn).to include(supporting_point.id)
      
    end
    
    it "does not get private points" do
      
      private_point = @user.current_lesson.points.sample
      private_point.update_attribute :is_private, true
      ids_of_new_points_to_learn = @user.new_points_to_learn(100).map(&:id)
      
      expect(ids_of_new_points_to_learn).not_to include(private_point.id)
      
    end
    
  end  
    
  describe "put_points_to_bag" do
    
    before :each do
      
      create_badge_types
      10.Points.belongs_to(2.Lessons)
      @user.update_attribute :current_lesson, Lesson.first
      @point1, @point2 = Point.limit(2)
      @point_ids = [@point1.id, @point2.id]
      
      @level1, @level2, @level3 = 3.Levels
      
      @review_data = [
        {point_id: @point1.id, skill_symbol: :interpret, reminded_times: 1, is_mastered: false},
        {point_id: @point1.id, skill_symbol: :grammar, reminded_times: 1, is_mastered: false},
        {point_id: @point1.id, skill_symbol: :verbal, reminded_times: 1, is_mastered: false},
        {point_id: @point2.id, skill_symbol: :interpret, reminded_times: 1, is_mastered: false},
        {point_id: @point2.id, skill_symbol: :grammar, reminded_times: 1, is_mastered: false},
        {point_id: @point2.id, skill_symbol: :verbal, reminded_times: 1, is_mastered: false},        
      ]
      
    end
    
    it "adds points to user's point bag" do          
      
      @user.put_points_to_bag(@review_data)
      
      expect(@user.points.map(&:id).sort).to eq [@point1.id, @point2.id].sort
      
    end
    
    it 'does not add the same point twice' do
      
      @user.put_points_to_bag(@review_data)
      @user.put_points_to_bag(@review_data)
      
      expect(@user.points.size).to be 2
      
    end
    
    it 'does not add points that are invalid and not supporting' do
      
      @point1.update_attributes is_valid: false, is_supporting: false
      @user.put_points_to_bag(@review_data)
      
      expect(@user.points.map(&:id)).not_to include(@point1.id)
      
    end
    
    it 'add valid points and supporting points' do
      
      @point1.update_attributes is_private: false, is_valid: true, is_supporting: false
      @point2.update_attributes is_private: false, is_valid: false, is_supporting: true
      @user.put_points_to_bag(@review_data)
      
      expect(@user.points.map(&:id)).to include(@point1.id)
      expect(@user.points.map(&:id)).to include(@point2.id)
      
    end
    
    it 'sets the number of effectively reviewed times of the skills to 3 if reminded_times param is 0' do
      
      @review_data[0][:reminded_times] = 0

      @user.put_points_to_bag(@review_data)
      
      expect(
        @user
        .review_skills
        .where(['reviews.point_id = ?', @point1.id])
        .where(['review_skills.skill = ?', ReviewSkill::SKILLS.fetch(:interpret)])
        .first
        .effectively_reviewed_times
      ).to be 3
      
    end
    
    it 'sets the number of effectively reviewed times of the skills to 10 if is_mastered param is true' do
      
      @review_data[0][:is_mastered] = true

      @user.put_points_to_bag(@review_data)
      
      expect(
        @user
        .review_skills
        .where(['reviews.point_id = ?', @point1.id])
        .where(['review_skills.skill = ?', ReviewSkill::SKILLS.fetch(:interpret)])
        .first
        .effectively_reviewed_times
      ).to be 10
      
    end
    
    it 'calls ReviewSkill#build_skills to build new skills' do
      
      @user.put_points_to_bag(@review_data)
      
      review_id = @user.reviews.first.id
      
      [@point1, @point2].each do |point|
        point.update_attributes is_private: false, is_valid: true
      end
      
      ReviewSkill::SKILLS_TO_BUILD.fetch(:private).each do |skill_symbol|
        
        review_skill = ReviewSkill.find_by skill: ReviewSkill::SKILLS.fetch(skill_symbol), review_id: review_id
        
        expect(review_skill).not_to be nil
        expect(review_skill.effectively_reviewed_times).to be 1
        expect(review_skill.reviewed_times).to be 1
        expect(review_skill.last_reviewed_date).to eq today
        expect(review_skill.reminded_times).to be 0        
        expect(review_skill.review_due_date).to be > today
        
      end
      
    end  
    
    it "updates user's score" do
      expect{@user.put_points_to_bag(@review_data)}.to change{@user.score}.by(6) # 2 points x 3 = 6
    end
    
    it "returns added score" do
      result = @user.put_points_to_bag(@review_data)
      expect(result[:score_change]).to be 6 # 2 points x 3 = 6
    end
    
    context "points put to the user's point bag that have been gotten from a lesson different from current lesson" do
      
      it "updates the user's current lesson" do
        
        (*, current_lesson, lesson3 = 3.Lessons).belongs_to(1.Syllabus).each_has_3_points
        
        @user.update_attribute :current_lesson, current_lesson
        
        @point2.update_attribute :lesson, lesson3
        
        @user.put_points_to_bag(@review_data)
        
        expect(@user.reload.current_lesson.id).to be lesson3.id          
        
      end
      
    end
    
    context "user's level has not changed" do
      
      it "returns 0" do
        @user.update_attributes level_id: @level2.id, score: @level1.highest_score + 1
        result = @user.put_points_to_bag(@review_data)
        expect(result[:level_changed]).to be 0
      end
      
    end
    
    context "user's level has gone up" do
      
      before :each do
        @user.update_attributes level_id: @level2.id, score: @level2.highest_score - 1
        @result = @user.put_points_to_bag(@review_data)
      end
      
      it "updates user's level" do
        expect(@user.reload.level_id).to be @level3.id
      end
      
      it "returns 1" do
        expect(@result[:level_changed]).to be 1
      end
      
    end
    
    it "creates a 'ReviewPoint' action and returns the action id" do
      result = @user.put_points_to_bag(@review_data)
      expect(UserReviewPointAction.count).to be 1
      expect(result[:action_id]).not_to be nil
    end
    
    it "provides necessary data for notifications to be sent correctly" do
      
      (@friend1, @friend2, @friend3 = 3.Users).serial_update(score: [1, 2, 30])
      [@level1, @level2, @level3].serial_update(highest_score: [2, 4, 6])
      @user.has_friendships([{friend_id: @friend1.id}, {friend_id: @friend2.id}, {friend_id: @friend3.id}])
      @user.update_attributes(score: 1, level: @level1)
      
      result = @user.put_points_to_bag(@review_data) # + 10 score after being processed
      
      expect(result[:overcome_friends].sort).to eq [@friend1.name, @friend2.name].sort
      
      #check notifications are created correctly
      expect(NotificationPointReviewed.count).to be > 1
      expect(NotificationOvercomeFriend.count).to be > 1
      expect(NotificationReachNewLevel.count).to be > 1
      
      expect { # test if notifications are sent correctly
        NotificationFinishLesson.all.map(&:process)
        NotificationOvercomeFriend.all.map(&:process)
        NotificationReachNewLevel.all.map(&:process)
      }.not_to raise_exception
      
    end
    
    describe "review summary data" do
      
      it "updates review sumary data" do
        
        review_summary = ReviewSummary.create! user_id: @user.id, date: today - 1.day, continuous_reviewing_days: 10, number_of_reviewed_items_today: 10
      
        result = @user.put_points_to_bag(@review_data)
        
        review_summary.reload
        
        expect(review_summary.continuous_reviewing_days).to be 11
        expect(review_summary.number_of_reviewed_items_today).to be 2
        
      end
      
      it "returns any detected opportunity" do
        
        create_badge_types
        
        badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first(3).last
        FactoryBot.create :review_summary, user_id: @user.id, date: today, number_of_reviewed_items_today: badge_type.number_of_efforts_to_get
        
        result = @user.put_points_to_bag(@review_data)
        
        opportunity = result[:opportunity]
        expect(opportunity).not_to be nil
        expect(opportunity.user_id).to be @user.id
        expect(opportunity.badge_type.id).to eq badge_type.id
        expect(opportunity.is_taken).to be false
        
      end
      
    end
    
    describe "rewarded lucky stars" do
      
      it 'calls Badge.toss_lucky_stars_to_user to decide the number of lucky stars to reward to the user' do
        expect(Badge).to receive(:toss_lucky_stars_to_user)
        @user.put_points_to_bag(@review_data)
      end
      
      it 'returns the number of lucky stars to reward to the user' do
        allow(Badge).to receive(:toss_lucky_stars_to_user).and_return(7)
        result = @user.put_points_to_bag(@review_data)
        expect(result[:number_of_rewarded_lucky_stars]).to be 7
      end
      
    end
    
  end
      
  describe 'password=' do
    
    describe 'create new user' do
      
      before :each do
        @new_user = FactoryBot.build :user
      end
      
      it 'should create salt' do        
        expect(@new_user.salt).not_to be_blank
      end
      
      it 'should create hashed_password' do
        expect(@new_user.hashed_password).not_to be_blank
      end
      
    end
    
    describe 'update password for user' do
      
      it 'should not create salt' do
        expect{ @user.password = 'somenewpassword'}.not_to change{@user.salt}
      end
      
      it 'should change hashed_password' do
        expect{ @user.password = 'somenewpassword' }.to change{@user.hashed_password} 
      end              
      
      it 'keeps hashed password unchanged if passed-in value is blank' do
        expect{ @user.password = ''}.not_to change{@user.hashed_password}
      end
      
    end
      
  end
  
  describe 'User#authenticate' do
      
    it 'returns user object with correct email and password' do      
      expect(User.authenticate(@user.email, @user.password)).to eq @user
    end
        
    it 'returns nil with wrong email' do
      expect(User.authenticate("wrongemail@mail.com", @user.password)).to be_nil  
    end
          
    it 'returns nil with wrong password' do
      expect(User.authenticate(@user.email, "wrongpassword")).to be_nil        
    end
    
  end
  
  describe "User#authenticate_by_recovering_password" do
    
    before :each do
      @user.update_attribute :recovering_password, 'recovering_password'
    end
    
    it 'returns user object with correct email and recovering password' do
      expect(User.authenticate_by_recovering_password(@user.email, 'recovering_password')).to eq @user
    end
    
    it "sets password to recovering password if the authentication succeeds" do
      User.authenticate_by_recovering_password(@user.email, 'recovering_password')
      expect(@user.reload.has_password?('recovering_password')).to be true
    end
    
    it 'returns nil with wrong email' do
      expect(User.authenticate_by_recovering_password("wrongemail@mail.com", 'recovering_password')).to be nil  
    end
          
    it 'returns nil with wrong recovering password' do
      expect(User.authenticate_by_recovering_password(@user.email, "wrong_recovering_password")).to be nil        
    end
    
  end
  
  describe 'authenticate_with_salt' do     
      
    it 'should return user object with correct salt' do
      expect(User.authenticate_with_salt(@user.id,@user.salt)).to eq @user
    end
    
    it 'should return nil with wrong salt' do
      expect(User.authenticate_with_salt(@user.id,"not_a_correct_sault")).to be_nil
    end
    
  end
  
  describe 'has_password?' do
    
    it 'returns true if the passed in value matches password' do
      expect(@user.has_password?(@user.password)).to be true
    end
    
    it 'returns false if the passed in value does not match password' do
      expect(@user.has_password?('wrong_password')).to be false
    end
    
  end
  
  describe 'has_recovering_password?' do
    
    before :each do
      @user.update_attribute :recovering_password, 'recovering_password'
    end
    
    it 'returns true if the passed in value matches recovering password' do
      expect(@user.has_recovering_password?(@user.recovering_password)).to be true
    end
    
    it 'returns false if the passed in value does not match recovering password' do
      expect(@user.has_recovering_password?('wrong_recovering_password')).to be false
    end
    
  end  

  describe 'set_recovering_password' do
    it 'sets recovering password successfull event if the user has invalid data' do
      @user.first_name = nil
      @user.save(validate: false)
      expect(@user.valid?).to be false
      @user.set_recovering_password('recovering_password')
      expect(@user.reload.has_recovering_password?('recovering_password')).to be true
    end
  end
  
  describe 'confirm_registration method' do
    
    before :each do
      @inviter = FactoryBot.create :user, :email => 'inviter@abc.com'
      @inviter.invitations.create(:receiver_email => @user.email)
      @user.update_attribute :status, User::STATUSES[:not_confirmed]
    end
    
    describe 'with correct confirmation_hash' do
                            
      it 'should activate user' do          
        expect{ 
          @user.confirm_registration(@user.confirmation_hash)        
        }.to change{@user.reload.status}.from(User::STATUSES[:not_confirmed]).to(User::STATUSES[:active])
      end
      
      it 'should add current user as friend of inviter' do          
        @user.confirm_registration(@user.confirmation_hash)           
        expect(@inviter.friends.map(&:id)).to include(@user.id)  
      end
      
    end
    
    describe 'with incorrect confirmation_hash' do
    
      it 'should not activate user' do
        expect{ 
          @user.confirm_registration("wrong_confirmation_hash")        
        }.not_to change{@user.reload.status}
      end
      
      it 'should not add current user as friend of inviter' do          
        @user.confirm_registration(@user.confirmation_hash)          
        expect(@inviter.friends.map(&:id)).to include(@user.id)  
      end
    
    end
    
  end  
  
  describe 'activate method' do      
    it 'should change the user status to active' do
      @user.update_attribute :status, User::STATUSES[:not_confirm]
      expect{@user.activate}.to change{@user.reload.status}.to(User::STATUSES[:active])  
    end
    
  end
  
  describe 'is_status? methods' do
    
    it 'should return true if user status matches {status}' do
      statuses = [:active, :not_confirmed]
      statuses.each do |status|
        @user.status = User::STATUSES[status]
        expect(@user.is_status?(status)).to be true
      end
    end
    
    it 'should return false if user status does not match {status}' do
      statuses = [:active, :not_confirmed]
      statuses.each do |status|
        @user.status = 1000
        expect(@user.is_status?(status)).to be false
      end
    end
    
    it 'should raise exception if {status} is not valid' do      
      expect { @user.is_status?(:no_valid) }.to raise_exception(Exception)
    end
    
  end
  
  describe 'friend_with? method' do
    
    before :each do      
      @another_user = FactoryBot.create :user, :email => 'anotheruser@abc.com'
    end
    
    it 'should return false if two users are not friends' do
      expect(@user.friend_with?(@another_user)).to be false
    end
    
    it 'should return true if passed-in user is a friend' do
      @user.friends << @another_user        
      expect(@user.friend_with?(@another_user)).to be true
      expect(@another_user.friend_with?(@user)).to be false
    end
    
  end  
  
  describe 'top_friends' do
    
    before :each do
      
      3.Users
      
      @user, @friend1, @friend2, @friend3 = User.first, User.third, User.fourth, User.second
      
      @user.update_attribute :score, 40
      @friend1.update_attribute :score, 30
      @friend2.update_attribute :score, 20
      @friend3.update_attribute :score, 10
                              
      @user.has_friendships([{friend_id: @friend1.id}, {friend_id: @friend2.id}, {friend_id: @friend3.id}])
      
    end
    
    it 'orders user and friends according to score' do
      
      expect(@user.top_friends.map(&:id)).to eq [@user, @friend1, @friend2, @friend3].map(&:id)
      
    end
    
    it 'does not include non-friend users' do
      
      @not_a_friend = User.one
      @not_a_friend.update_attribute :score, 40
      
      expect(@user.top_friends.map(&:id).include?(@not_a_friend.id)).to be false
      
    end
    
    it 'returns the right number of users according passed-in max parameter' do
      maxs = [2,3]
      maxs.each do |max|
        expect(@user.top_friends(max).map(&:id).count).to be max
      end
    end
    
  end
  
  describe 'send_invitations_to' do
    
    before :each do
      
      @unregistered_emails = ['new@example.com', 'new2@example.com']
      
      @registered_emails   = ['existing@example.com', 'existing2@example.com']
      User.has @registered_emails.map{|email| {email: email} }
     
      @user.send_invitations_to(@registered_emails + @unregistered_emails)        
      
    end
    
    it 'only sends invitation to unregistered emails' do
              
      expect(@user.invitations.map(&:receiver_email)).to eq @unregistered_emails
        
    end          
    
    it 'makes members with registered emails become friends' do
      
      expect(@user.friends.map(&:email)).to eq @registered_emails
      
    end
    
    it 'does not raise error if passed-in array of emails is empty' do
      expect{ @user.send_invitations_to [] }.not_to raise_error
    end
    
  end
  
  describe 'pick_friend_emails' do
    
    before :each do
      
      @friend_emails   = ['friend1@example.com', 'friend2@example.com']
      @stranger_emails = ['strainger1@example.com', 'strainger2@example.com']
      
      friends = User.has( @friend_emails.map{|friend_email| { email: friend_email } } )
      @user.has_friendships( friends.map{|friend| { friend_id: friend.id } } )
      
    end
    
    it "picks out friends' emails from a list of email" do
                    
      expect(@user.pick_out_emails_of_friends( @friend_emails + @stranger_emails ).sort).to eq @friend_emails.sort
      
    end
    
    it "returns an empty array if there are no friends's mails" do
      
      expect(@user.pick_out_emails_of_friends( @stranger_emails )).to eq []
      
    end
    
  end
  
  describe 'previous_active_lessons' do
    
    before :each do
      
      25.Lessons.belongs_to 5.Syllabuses

      Syllabus.first.update_attribute(:syllabus_order, Syllabus.last.syllabus_order + 1)
      
      Syllabus.all.each {|syllabus| syllabus.lessons.last.move_higher  } # change lesson position
        
      Lesson.first.update_attribute :active, false        
      
      @current_syllabus = Syllabus.order(:syllabus_order).first(3).last
      
      current_lesson = @current_syllabus.lessons.order(:position).first(3).last
          
      @user.current_lesson = current_lesson
      
      @user.save
      
    end
    
    it 'contains all active lessons from previous syllabus' do
                    
      previous_syllabuses = Syllabus.where(['syllabus_order < ?',  @user.current_lesson.syllabus.syllabus_order]).map(&:id)
      
      active_lessons_from_previous_syllabuses =  Lesson.where(['active = ? AND syllabus_id IN (?)', true, previous_syllabuses]).map(&:id).sort
      
      previous_active_lessons = @user.previous_active_lessons.map(&:id).sort
      
      expect(( previous_active_lessons & active_lessons_from_previous_syllabuses )).to eq active_lessons_from_previous_syllabuses
      
    end
    
    it 'contains all previous active lessons from current syllabus and the current lesson' do
      
      previous_active_lessons_from_current_syllabus = Lesson.where(['active = ? AND syllabus_id = ? AND position <= ?', true, @user.current_lesson.syllabus.id, @user.current_lesson.position]).map(&:id).sort
      
      previous_active_lessons = @user.previous_active_lessons.map(&:id).sort
      
      expect(( previous_active_lessons & previous_active_lessons_from_current_syllabus )).to eq previous_active_lessons_from_current_syllabus
      
    end
    
  end
    
  describe 'calculate_score' do
    
    before :each do
      
      @point1, @point2, @point3 = 3.Points
      
      @data = [
        {:effectively_reviewed_times => 0},
        {:effectively_reviewed_times => 1},
        {:effectively_reviewed_times => 2}
      ]
      
      @review, @review1, @review2 = @user.has_reviews([{point_id: @point1.id}, {point_id: @point2.id}, {point_id: @point3.id}], :assoc)
      
    end
    
    it "calculate user's score by summing up effective review times of user points" do
      
      @review.has_review_skills(@data)
      
      expect(@user.calculate_score).to be 3
      
    end
    
    it "ignores effective review times which is greater than 10" do
      
      @data.push({:effectively_reviewed_times => 11})
      
      @review.has_review_skills(@data)
      
      expect(@user.calculate_score).to be 13
      
    end
    
    it "accepts an array of point ids to calculate score" do
      
      @review.has_review_skills [{:effectively_reviewed_times => 0}]
      @review1.has_review_skills [{:effectively_reviewed_times => 1}]
      @review2.has_review_skills [{:effectively_reviewed_times => 2}]
      
      expect(@user.calculate_score([@point1.id, @point2.id])).to be 1
      
    end
    
    it "returns 0 if an empty array is passed in" do
      
      @user.has_review_skills(@data, :assoc)
      
      expect(@user.calculate_score([])).to be 0
      
    end
  
  end

  describe 'process_review' do
    
    before :each do
      
      create_badge_types
            
      @level1, @level2, @level3 = 3.Levels
      
      @point1, @point2 = 2.Points
      
      @review1, @review2 = @user.has_2_reviews(:assoc).belongs_to [@point1, @point2]
      
      @interpret_1, @verbal_1, @grammar_1 = @review1.has_review_skills([
        {:effectively_reviewed_times => 0, skill: ReviewSkill::SKILLS.fetch(:interpret)},        
        {:effectively_reviewed_times => 1, skill: ReviewSkill::SKILLS.fetch(:verbal)},
        {:effectively_reviewed_times => 2, skill: ReviewSkill::SKILLS.fetch(:grammar)}
      ], :assoc)
      
      @interpret_2, @verbal_2, @grammar_2 = @review2.has_review_skills([
        {:effectively_reviewed_times => 0, skill: ReviewSkill::SKILLS.fetch(:interpret)},        
        {:effectively_reviewed_times => 1, skill: ReviewSkill::SKILLS.fetch(:verbal)},
        {:effectively_reviewed_times => 2, skill: ReviewSkill::SKILLS.fetch(:grammar)}
      ], :assoc)
      
      score = @user.calculate_score
      @user.update_attributes level: Level.get_level_for_score(score), score: score
      
    end
    
    it 'sets effectively reviewed times correctly' do
            
      review_data = [
        [@interpret_1.id, 0],
        [@verbal_1.id, 1],
        [@verbal_2.id, 2],
        [@grammar_2.id, 3],        
      ]
      
      @user.process_review(review_data)
      
      expect(@interpret_1.reload.effectively_reviewed_times).to be 1
      expect(@verbal_1.reload.effectively_reviewed_times).to be 1
      expect(@verbal_2.reload.effectively_reviewed_times).to be 1
      expect(@grammar_2.reload.effectively_reviewed_times).to be 1
          
    end
        
    it 'sets the number of effectively reviewed times for the skills correctly if mastered_skills parameter is passed' do
      
      review_data = [
        [@interpret_1.id, 0, true],
        [@verbal_1.id, 1, false]
      ]
      
      @user.process_review(review_data)
      
      expect(@interpret_1.reload.effectively_reviewed_times).to be 10
      
    end
        
    it "updates user's core" do
                  
      review_data = [
        [@interpret_1.id, 0], # + 1 score after being processed
        [@verbal_1.id, 1], # + 0 score after being processed
        [@verbal_2.id, 2], # + 0 score after being processed
        [@grammar_2.id, 3] # - 1 score after being processed
      ]
      
      expect{@user.process_review(review_data)}.to change{@user.score}.by(0)
      
    end
    
    it "returns score change" do
      
      review_data = [
        [@interpret_1.id, 0], # + 1 score after being processed
        [@verbal_1.id, 1] # + 0 score after being processed
      ]
      
      result = @user.process_review(review_data)
      expect(result[:score_change]).to be 1
      
    end
    
    #context "verbal skill is reviewed" do
      
      #before :each do
      #  example = FactoryBot.create :example, point_id: @point1.id, is_main: true
      #  @point1.update_attributes main_example_id: example.id
      #  example.has_example_point_links([{point_id: @point2.id}])
      #end
      
      #it "considers interpret skill of linked words as reviewed" do
      #  expect{ @user.process_review([[@verbal_1.id, 0]]) }.to change{@interpret_2.reload.effectively_reviewed_times}.by(1)
      #end
      
      #it "does not consider non-interpret skills of linked words as reviewed" do
      #  expect{ @user.process_review([[@verbal_1.id, 0]]) }.not_to change{@grammar_2.reload.effectively_reviewed_times}
      #end
      
      #it "does not consider interpret skills of linked words as reviewed if the proccessed skill is non-verbal" do
      #  expect{ @user.process_review([[@interpret_1.id, 0]]) }.not_to change{@interpret_2.reload.effectively_reviewed_times}
      #end
      
      #it "does not consider linked interpret skills of other users as reviewed" do
        
      #  user2 = User.one
      #  review, review2 = user2.has_2_reviews(:assoc).belongs_to [@point1, @point2]
      
      #  interpret, verbal, grammar = review2.has_review_skills([
      #    {:effectively_reviewed_times => 0, skill: ReviewSkill::SKILLS.fetch(:interpret)},        
      #    {:effectively_reviewed_times => 1, skill: ReviewSkill::SKILLS.fetch(:verbal)},
      #    {:effectively_reviewed_times => 2, skill: ReviewSkill::SKILLS.fetch(:grammar)}
      #  ], :assoc)
      #  
      #  expect{ @user.process_review([[@verbal_1.id, 0]]) }.not_to change{interpret.reload.effectively_reviewed_times}
        
      #end
    
    #end
    
    context "level change" do
      
      before :each do                  
        
        @review_data = [
          [@interpret_1.id, 0], # + 1 score after being processed
          [@verbal_1.id, 0] # + 1 score after being processed
        ]
        
      end
      
      context "user's level has gone up" do
        
        before :each do
          @old_level = @user.level
          @user.level.update_attributes highest_score: @user.score + 1
          @result = @user.process_review(@review_data)
        end
        
        it "updates user's level" do
          expect(@user.reload.level.id).to eq @old_level.id + 1
        end
        
        it "returns 1" do
          expect(@result[:level_changed]).to be 1
        end
        
      end
      
      it "returns 0 if user's level has not changed" do
        result = @user.process_review(@review_data)
        expect(result[:level_changed]).to be 0
      end
      
      it "returns -1 if user's level has gone down" do
        @review_data = [
          [@grammar_2.id, 3] # - 2 score after being processed
        ]
        @user.update_attributes level_id: @level2.id, score: @level1.highest_score + 1
        result = @user.process_review(@review_data)
        expect(result[:level_changed]).to equal(-1)
      end
      
    end          
    
    it "creates a 'ReviewPoint' action and returns the action id" do
      
      review_data = [
        [@interpret_1.id, 0], # + 1 score after being processed
        [@verbal_1.id, 1] # + 1 score after being processed
      ]
      
      result = @user.process_review(review_data)
      
      expect(UserReviewPointAction.count).to be 1
      expect(result[:action_id]).not_to be nil
      
    end
    
    it "provides necessary data for notifications to be sent correctly" do
      
      (@friend1, @friend2, @friend3 = 3.Users).serial_update(score: [@user.score, @user.score + 1, @user.score + 2])
      [@level1, @level2, @level3].serial_update(highest_score: [2, 4, 6])
      @user.has_friendships([{friend_id: @friend1.id}, {friend_id: @friend2.id}, {friend_id: @friend3.id}])
      @user.update_attributes(level: @level1)
      
      review_data = [
        [@interpret_1.id, 0], # + 1 score after being processed
        [@verbal_1.id, 0] # + 1 score after being processed
      ]
      
      result = @user.process_review(review_data)
      
      expect(result[:overcome_friends].sort).to eq [@friend1.name, @friend2.name].sort
      
      #check notifications are created correctly
      expect(NotificationPointReviewed.count).to be > 1
      expect(NotificationOvercomeFriend.count).to be > 1
      expect(NotificationReachNewLevel.count).to be > 1
      
      expect { # test if notifications are sent correctly
        NotificationFinishLesson.all.map(&:process)
        NotificationOvercomeFriend.all.map(&:process)
        NotificationReachNewLevel.all.map(&:process)
      }.not_to raise_exception
      
    end
    
    describe "review summary data" do
      
      it "updates review sumary data" do
        
        review_summary = ReviewSummary.create! user_id: @user.id, date: today - 1.day, continuous_reviewing_days: 10, number_of_reviewed_items_today: 10
      
        result = @user.process_review( [[@interpret_1.id, 0], [@verbal_1.id, 0]] )
        
        review_summary.reload
        
        expect(review_summary.continuous_reviewing_days).to be 11
        expect(review_summary.number_of_reviewed_items_today).to be 2
        
      end
      
      it "returns any detected opportunity" do
        
        create_badge_types
        
        badge_type = BadgeType.where(badge_type: 'warrior').order("number_of_efforts_to_get ASC").first(3).last
        FactoryBot.create :review_summary, user_id: @user.id, date: today, number_of_reviewed_items_today: badge_type.number_of_efforts_to_get
        
        result = @user.process_review( [[@interpret_1.id, 0], [@verbal_1.id, 0]] )
        
        opportunity = result[:opportunity]
        expect(opportunity.user_id).to be @user.id
        expect(opportunity).not_to be nil
        expect(opportunity.badge_type.id).to eq badge_type.id
        expect(opportunity.is_taken).to be false
        
      end
      
    end
    
    describe "rewarded lucky stars" do
      
      it 'calls Badge.toss_lucky_stars_to_user to decide the number of lucky stars to reward to the user' do
        expect(Badge).to receive(:toss_lucky_stars_to_user)
        @user.process_review( [[@interpret_1.id, 0], [@verbal_1.id, 0]] )
      end
      
      it 'returns the number of lucky stars to reward to the user' do
        allow(Badge).to receive(:toss_lucky_stars_to_user).and_return(7)
        result = @user.process_review( [[@interpret_1.id, 0], [@verbal_1.id, 0]] )
        expect(result[:number_of_rewarded_lucky_stars]).to be 7
      end
      
    end
        
  end
  
  describe "name" do      
    it "returns middle name + first name if middle name is present" do
      @user.update_attributes first_name: 'Vi', middle_name: 'Quoc', last_name: 'Dang'
      expect(@user.name).to eq "Quoc Vi"
    end
    it "returns first name + first name if middle name is not present" do
      @user.update_attributes first_name: 'Vi', middle_name: '', last_name: 'Dang'
      expect(@user.name).to eq "Dang Vi"
    end
  end
  
  describe 'User#generate_password' do
    
    it 'generates a password that starts with 3 letters and ends with 3 digits' do
      
      password = User.generate_password
      
      expect(password.length).to be 6
      
      expect(password).to match(/[a-z]{3}[0-9]{3}/)
      
    end
    
  end 
    
  describe 'today_reviewed_skills_exist' do
    
    before :each do
      
      @review1, @review2 = @user.has_2_reviews(:assoc).belongs_to(2.Points)
      
      @review1.has_review_skills([
        {skill: ReviewSkill::SKILLS.fetch(:interpret), :last_reviewed_date => Date.today - 1.day},
        {skill: ReviewSkill::SKILLS.fetch(:grammar), :last_reviewed_date => Date.today}
      ]);
      
      @review2.has_review_skills([
        {skill: ReviewSkill::SKILLS.fetch(:verbal), :last_reviewed_date => Date.today - 2.day},
        {skill: ReviewSkill::SKILLS.fetch(:grammar), :last_reviewed_date => Date.today - 3.day},
      ]);
      
      @point_not_in_bag = 1.Point.first
      
    end
    
    it 'returns true if there is at least one skill already reviewed today' do
      expect(@user.today_reviewed_skills_exist?([
        [@review1.point_id, "grammar"], #this skill has been reviewed today
        [@review1.point_id, "interpret"], 
        [@review2.point_id, "grammar"]
      ])).to be true
    end
    
    it 'returns false if there are no skills already reviewed today' do
      expect(@user.today_reviewed_skills_exist?([
        [@review1.point_id, "interpret"],
        [@review2.point_id, "grammar"],
        [@point_not_in_bag.id, "interpret"]
      ])).to be false
    end
    
  end
  
  describe 'friend_add' do
    
    before :each do
      @other_user = User.one
    end
    
    it 'adds other user as a friend' do
      @user.friend_add(@other_user)
      expect(@user.friends.map(&:id)).to include(@other_user.id)
      expect(@other_user.friends.map(&:id)).to include(@user.id)
    end
    
    it 'does not add the same user twice' do
      @user.friend_add(@other_user)
      @user.friend_add(@other_user)
      expect(@user.friends.map(&:id)).to eq [@other_user.id]
    end
    
  end
  
  describe 'unfriend' do
    
    it 'unfriends other user' do
      @other_user = User.one
      @user.friend_add(@other_user)
      @user.unfriend(@other_user)
      expect(@user.friends.reload.map(&:id)).not_to include(@other_user.id)
      expect(@other_user.friends.map(&:id)).not_to include(@user.id)  
    end
    
  end
      
end