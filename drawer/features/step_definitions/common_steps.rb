Given(/^I have signed in$/) do
  @user = User.one.belongs_to(Level.one).belongs_to_current_lesson(Lesson.one)  
  signin @user  
end