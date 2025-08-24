require 'spec_helper'

describe Point do
  
  before :each do
    stub_network_calls_that_get_data_for_points
  end
  
  describe 'validations' do
    
    subject do
      FactoryBot.create(:point)
    end      
    
    it { is_expected.to validate_presence_of(:content) }
    
    it { is_expected.to validate_presence_of(:lesson_id) }
    
    it { is_expected.to validate_presence_of(:meaning) }
    
    it { is_expected.to validate_presence_of(:point_type) }
      
  end 
  
  describe 'methods' do
    
    describe 'random_example' do
      
      it 'takes an example randomly' do
        
        point = Point.one.has_3_examples
        
        ids = []
        
        30.times do
          ids << point.random_example.id
        end
        
        expect(ids.uniq.sort).to eq point.examples.map(&:id).sort
        
      end
      
    end
    
    describe 'is_word?' do
      
      it "returns true if string contains only [a-z] characters, dashes or underscores" do
        
        ['a', 'word', 'a-word', 'a_word'].each do |string|
          expect(Point.is_word?(string)).to be true
        end
        
      end
      
      it 'returns false if string starts or ends with a dash or an underscore' do
        
        ['_word', '-word', 'word_', 'word-'].each do |string|
          expect(Point.is_word?(string)).to be false
        end  
        
      end
      
    end
    
    describe 'is_phase?' do
            
      it 'returns false if string is a word' do
        
        expect(Point.is_phase?('word')).to be false
        
      end
            
      
    end
    
    describe 'update_validity' do
            
      before :each do
        
        @point = Point.one
        
        @example = Example.one
        @example.point = @point
        @example.is_main = true
        @example.save        
        
        @question = Question.one
        @question.update_attribute :is_valid, true
        @question.belongs_to @point
        
        expect(@point.is_valid).to be false
        
      end
      
      it 'updates is_valid attribute to true if point has a main example and at least one valid question' do
                                  
        expect{ @point.update_validity }.to change(@point, :is_valid).from(false).to(true)            
        
      end
      
      it 'updates is_valid attribute to false if point does not have a main example' do
        
        @point.update_attribute :main_example_id, 0
        
        expect{ @point.update_validity }.not_to change(@point, :is_valid)
        
      end
      
      it 'updates is_valid attribute to false if point does not have a valid question' do
        
        @question.update_attribute :is_valid, false
        
        expect{ @point.update_validity }.not_to change(@point, :is_valid)
        
      end
      
    end
    
    describe 'find_highest_lesson_in_points' do
      
      it "returns id of the highest lesson in points" do
        (lesson1, lesson2, lesson3 = 3.Lessons).serial_update(position: [1,2,3]).has_10_points
        point_ids = [lesson1.points.sample, lesson3.points.sample].map(&:id)
        expect(Point.find_highest_lesson_in_points(point_ids).id).to be lesson3.id
      end
      
    end
    
    describe 'Class#get_by_ids' do
      
      before :each do
        @p1, @p2, @p3, @p4 = 4.Points
      end
      
      it 'loads the right points' do
        
        points = Point.get_by_ids([@p1.id, @p3.id])
        
        expect(points.map(&:id)).to eq [@p1.id, @p3.id]
        
      end
      
      it 'returns points in the correct order' do
        
        points = Point.get_by_ids([@p4.id, @p2.id, @p3.id, @p1.id])
        
        expect(points.map(&:id)).to eq [@p4.id, @p2.id, @p3.id, @p1.id]
        
      end
      
    end
    
    describe 'Class#search_by_user' do
      
      before :each do
        @user, @other_user = User.create_2
      end
      
      describe "search by content" do
        
        before :each do
          @match1, @match2, @not_match , @match3 = Point.has([
            {content: 'match a'},
            {content: 'a match'},
            {content: 'shit'},
            {content: 'a match z'}
          ])
        end
        
        it 'returns points content of which match searched content' do
          expect(Point.search_by_user(@user.id, content:'match').map(&:id).sort).to eq [@match1.id, @match2.id, @match3.id].sort
        end
        
        it 'returns all points if no searched content is passed' do
          expect(Point.search_by_user(@user.id).map(&:id).sort).to eq [@match1.id, @match2.id, @not_match.id, @match3.id].sort
        end
        
      end
      
      it "sets 'is_in_bag' attribute to true if a returned point is in user's bag and the review item is active" do
        
        p1, p2 = Point.create_2
        
        @user.has_reviews [{point_id: p1.id}]
        @other_user.has_reviews [{point_id: p2.id}]
        
        points = Point.search_by_user(@user.id)
        
        expect(points.select{|p| p.is_in_bag == 1}.count).to be 1
        expect(points.select{|p| p.id == p1.id && p.is_in_bag == 1}.count).to be 1
        
      end
      
      it "sets 'is_in_bag' attribute to false if a returned point is in user's bag but the review item is not active" do
        
        p1, p2 = Point.create_2
        
        @user.has_reviews [{point_id: p1.id}]
        @user.reviews.update_all is_active: false
        @other_user.has_reviews [{point_id: p2.id}]
        
        points = Point.search_by_user(@user.id)
        
        expect(points.select{|p| p.is_in_bag == 1}.count).to be 0
        expect(points.select{|p| p.id == p1.id && p.is_in_bag == 1}.count).to be 0
        
      end
      
      describe 'search in different spaces' do
        
        before :each do
          
          @some_point,
          @in_user_bag,
          @added_by_user,
          @in_user_bag_and_added_by_user =
          
          Point.has([
            {content: 'some point'},
            {content: 'in user point bag'},
            {content: 'added by user', adding_user_id: @user.id},
            {content: 'in user bag and added by user', adding_user_id: @user.id},
          ])
          
          @user.has_reviews([{point_id: @in_user_bag.id}, {point_id: @in_user_bag_and_added_by_user.id}])
          
        end
        
        it 'searches all in points table if search_in set to :all' do
          expect(Point.search_by_user(@user.id, search_in: :all).map(&:id).sort).to eq [@some_point, @in_user_bag, @added_by_user, @in_user_bag_and_added_by_user].map(&:id).sort
        end
        
        it 'searches points only in user point bag if search_in set to :user_bag' do
          expect(Point.search_by_user(@user.id, search_in: :user_bag).map(&:id).sort).to eq [@in_user_bag.id, @in_user_bag_and_added_by_user.id].sort
        end
        
        it 'searches only points added by user if search_in set to :added_by_user' do
          expect(Point.search_by_user(@user.id, search_in: :added_by_user).map(&:id).sort).to eq [@added_by_user.id, @in_user_bag_and_added_by_user.id].sort
        end
        
        it 'raises error if seach_in is not :all, :user_bag or :added_by_user' do
          expect{Point.search_by_user(@user.id, search_in: 'all')}.to raise_error(Exception)
        end
        
      end
      
      it 'excludes private points added by other users, but includes private points added by user' do
        
        @added_by_user,
        @added_by_another_user =
        
        Point.has([
          {content: 'added by user', is_private: true, adding_user_id: @user.id},
          {content: 'added by another user', is_private: true, adding_user_id: User.one.id}
        ])
        
        point_ids = Point.search_by_user(@user.id, search_in: :all).map(&:id)
        
        expect(point_ids).to include(@added_by_user.id)
        
        expect(point_ids).not_to include(@added_by_another_user.id)
        
      end
        
    end
    
    describe 'Class#search_including_variations' do
      
      before :each do
        @user, @other_user = User.create_2
      end
      
      describe "search by content" do
        
        before :each do
          @point1, @point2 , @point3 = Point.has([
            {content: 'match'},
            {content: 'notmatch'},
            {content: 'match'},
          ])
        end
        
        it 'returns points content of which match searched key' do
          expect(Point.search_including_variations('match', @user.id).map(&:id).sort).to eq [@point1.id, @point3.id].sort
        end
        
        it 'return an empty array if no searched key is passed' do
          [nil, ''].each do |searched|
            expect(Point.search_including_variations(searched, @user.id)).to eq []
          end
        end
        
        it 'returns points that have at least one variation matching the searched key' do
          
          WordVariation.create!([{content: 'matching', point_id: @point1.id}])
          WordVariation.create!([{content: 'matching', point_id: @point3.id}])
          
          expect(Point.search_including_variations('matching', @user.id).map(&:id).sort).to eq [@point1.id, @point3.id].sort
        
        end
        
        it 'does not return duplicate points' do
          WordVariation.create!([{content: 'match', point_id: @point1.id}])
          WordVariation.create!([{content: 'match', point_id: @point1.id}])
          expect(Point.search_including_variations('match', @user.id).map(&:id).sort).to eq [@point1.id, @point3.id].sort
        end
        
        it 'returns expressions that contains the searched key or contains at least one variation of the searched key' do
          
          @point4 , @point5, @point6, @point7, @point8 = Point.has([
            {content: 'match part', point_type: 'exp'},
            {content: 'parting matches it', point_type: 'exp'},
            {content: 'part', point_type: 'v'},
            {content: 'apart', point_type: 'adv'},
            {content: 'does not match partings form', point_type: 'exp'},
          ])
          
          WordVariation.create!([{content: 'parting', point_id: @point6.id}])
          
          expect(Point.search_including_variations('parting', @user.id).map(&:id).sort).to eq [@point4.id, @point5.id,   @point6.id].sort
          
        end
        
        it 'excludes private points added by other users, but includes private points added by user' do
        
          @added_by_user,
          @added_by_another_user =
          
          Point.has([
            {content: 'added', is_private: true, adding_user_id: @user.id},
            {content: 'added', is_private: true, adding_user_id: User.one.id}
          ])
          
          point_ids = Point.search_including_variations('added', @user.id).map(&:id)
          
          expect(point_ids).to include(@added_by_user.id)
          
          expect(point_ids).not_to include(@added_by_another_user.id)
          
        end
        
        it 'excludes private expression added by other users, but includes private expression added by user' do
        
          @added_by_user,
          @added_by_another_user =
          
          Point.has([
            {content: 'added by user', point_type: 'exp', is_private: true, adding_user_id: @user.id},
            {content: 'added by another user', point_type: 'exp', is_private: true, adding_user_id: User.one.id}
          ])
          
          point_ids = Point.search_including_variations('added', @user.id).map(&:id)
          
          expect(point_ids).to include(@added_by_user.id)
          
          expect(point_ids).not_to include(@added_by_another_user.id)
          
        end
        
      end
      
    end
    
    describe 'Class#build_by_user_with_example' do
      
      before :each do
        
        data = {
          content: 'love',
          pronunciation: 'lʌv',
          point_type: 'n',
          meaning: 'tình yêu',
          main_example_attributes: {
            content: 'I need your love',
            meaning: 'Tôi cần tình yêu của em'
          }
        }
        
        @built_point = Point.build_by_user_with_example User.one, data
        
      end
      
      it 'creates a valid new point given neccessary data' do
        expect(@built_point.valid?).to be true
      end
      
      it "sets 'is_private' to true" do
        expect(@built_point.is_private).to be true
      end
      
    end
    
    describe 'Class#save_by_user_with_example' do
      
      before :each do
        
        User.create_2

        @user = User.one
        
        @attributes = {
          content: 'love',
          pronunciation: 'lʌv',
          point_type: 'n',
          meaning: 'tình yêu',
          main_example_attributes: {
            content: 'I need your love',
            meaning: 'Tôi cần tình yêu của em'
          }
        }
        
        @built_point = Point.build_by_user_with_example @user, @attributes
        
      end
      
      it 'saves the point with the main example, and the main example refers the point correctly' do
        Point.save_by_user_with_example @user.id, @built_point
        point = Point.last
        expect(point).not_to be nil
        expect(point.main_example).not_to be nil
        expect(point.main_example.point_id).to be point.id
      end
            
      it 'adds the newly created point to user bag' do
        
        @user.belongs_to Level.one
        Point.save_by_user_with_example @user.id, @built_point
        
        expect(@user.reviews.map(&:point_id)).to include(Point.first.id)        
        expect(@user.review_skills.count).to be 2
        expect(@user.review_skills.where(["review_skills.skill = ?", ReviewSkill::SKILLS.fetch(:interpret)]).count).to be 1
        
      end
      
    end
    
    describe 'add_point_for_user' do
      
      before :each do
        @user = User.one
        @point = Point.one
      end
      
      it 'adds the point to user bag' do
        Point.add_point_for_user(@point.id, @user.id)
        review = Review.first
        expect(review).not_to be nil
        expect(review.user_id).to be @user.id
        expect(review.point_id).to be @point.id
      end
      
      it 'updates is_active attribute of review item to true if the point is already in user bag' do
        Point.add_point_for_user(@point.id, @user.id)
        review = @user.reviews.find_by point_id: @point.id
        review.update_attribute :is_active, false
        Point.add_point_for_user(@point.id, @user.id)
        expect(review.reload.is_active).to be true
      end          
          
    end
    
  end
  
  describe 'callbacks' do
    
    context 'after creating' do           
      
      let(:point){ FactoryBot.build :point }
               
      it 'creates corresponding sound if none exists' do
        
        point.save
        expect(point.sound).not_to be_nil
        expect(point.sound.for_content).to eq(point.content)
        
      end
      
      it 'connects to corresponding sound if one exists' do
                       
        sound = Sound.create(:for_content => point.content)
        point.save
        expect(point.sound.id).to be sound.id
                
      end
      
      it 'searches and connects to dual sounds' do
        
        sounds = [ Sound.create(:for_content => "#{point.content}@1"), Sound.create(:for_content => "#{point.content}@2") ]
        point.save
        
        expect(sounds.map(&:id)).to be_include(point.sound.id)
        expect(sounds.map(&:id)).to be_include(point.sound2.id)
        expect(point.sound_verified).to be false
        
      end
      
      it 'searches pronunciation if it does not exist' do
        point.pronunciation = ''
        point.save
        expect(point.pronunciation).to eq 'lʌv'
      end
      
      it 'does not search pronunciation if it already exists' do
        point.pronunciation = 'pɔint'
        point.save
        expect(point.pronunciation).to eq 'pɔint'
      end
      
      it 'does not search pronuncation for private points' do
        point.pronunciation = ''
        point.is_private = true
        point.save
        expect(point.pronunciation).to eq ''
      end
      
    end
    
    context 'after updating' do
      
      let(:point){ Point.one }
                         
      context 'content changes' do
               
        it 'creates corresponding sound for new content if none exists' do
          
          point.content = 'new content'
          point.save
          expect(point.sound).not_to be_nil
          expect(point.sound.for_content).to eq(point.content)
          
        end
        
        it 'connects to corresponding sound for new content if one exists' do
                         
          sound = Sound.create(:for_content => 'new content')
          point.content = 'new content'
          point.save
          expect(point.sound.id).to be sound.id
                  
        end
        
        it 'removes previous sound if no point refers to it' do
          
          previous_sound = point.sound
          point.content = 'new content'
          point.save
          
          expect{ previous_sound.reload }.to raise_exception(Exception)
          
        end
        
        it 'does not remove previous sound if there are still points refering to it' do
          
          previous_sound = point.sound
          
          another_point = Point.one
          another_point.update_attribute 'sound_id', previous_sound.id
          
          point.content = 'new content'
          point.save
          
          expect{ previous_sound.reload }.not_to raise_exception()
          
        end
        
        it 'updates pronunciation' do
          point.content = 'new content'
          point.save
          expect(point.pronunciation).to eq 'lʌv'
        end
        
        it 'does not update pronuncation for private points' do
          current_pronunciation = point.pronunciation
          point.content = 'new content'
          point.is_private = true
          point.save
          expect(point.reload.pronunciation).to eq current_pronunciation
        end
      
      end
      
      context 'content unchanges' do
        
        it 'remains current sound' do
          
          current_sound = point.sound
          point.meaning_in_english = 'new explanation'
          point.save
          
          expect{ Sound.find(current_sound.id) }.not_to raise_exception()          
          expect(point.sound.id).to be current_sound.id
          
        end
        
        it 'does not update pronunciation' do
          current_pronunciation = point.pronunciation
          point.meaning_in_english = 'new explanation'
          point.save
          expect(point.pronunciation).to eq current_pronunciation
        end
        
      end
      
      context 'main_example changes' do
        
        before :each do
          @point = Point.one
          @point.main_example = Example.one
        end
                          
        it "tells the point to update it's validity" do
                                         
          expect_any_instance_of(Point).to receive(:update_validity)
          @point.save
          
        end
        
      end
      
      context 'main_example unchanges' do
        
        before :each do
          @point = Point.one
          @point.main_example = Example.one
          @point.save
        end
        
        it "does not tell the point to update it's validity" do
                                         
          expect_any_instance_of(Point).not_to receive(:update_validity)
          @point.content = 'new_content'
          @point.save
          
        end
        
      end
      
    end
    
  end
  
end
