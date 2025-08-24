require_relative '../spec_helper'

describe UserFinishLessonAction do
  
  describe "methods" do
    
    describe "process" do
      
      before :each do
        
        @user = User.one
        @friend1, @friend2, @friend3 = 3.Users
        @user.has_friendships([{friend_id: @friend1.id}, {friend_id: @friend2.id}, {friend_id: @friend3.id}])
        @level1, @level2, @level3 = 3.Levels
        
        @user_action = UserFinishLessonAction.new(
                                     user_id: @user.id,
                                     data: {
                                       old_level_id: @level1.id,
                                       new_level_id: @level1.id,
                                       score_change: 0
                                      }
                                    )
        
      end
        
      it "creates a 'FinishLesson' event" do
        @lesson = Lesson.one
        @user_action.data = @user_action.data.merge({lesson_id: @lesson.id, score_change: 2})
        @user_action.save # will call #process method
        event = UserFinishLessonEvent.first
        expect(event.from_action_id).to be @user_action.id
        expect(event.data[:score_change]).to be 2
        expect(event.data[:lesson_id]).to be @lesson.id
      end
      
    end
    
  end
  
end
