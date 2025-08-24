Then(/^I see my current level$/) do
  expect(page).to have_css("#current_level")
end

Then(/^I see a link to view my current lesson$/) do
  has_link href: lesson_path(@user.current_lesson)
end

Then(/^I see a link to take current lesson test$/) do
  has_link href: lesson_path(@user.current_lesson)
end

When(/^I visit home page$/) do
  visit root_path  
end

Given(/^I have some due points$/) do
  @user.current_lesson.has_5_points
  @user.add_points_of_current_lesson
  @user.user_points.first.update_attribute(:review_due_date, Date.today)
end

Then(/^I see a link to point review page$/) do
  has_link href: points_review_path
end

Given(/^I have no due points$/) do
   @user.user_points.destroy_all
end

Then(/^I do not see any link to point review page$/) do
  expect(page).not_to have_css("#current_lesson a[href='#{points_review_path}']")
end

Given(/^I have (\d+) friends$/) do |number|
  friends = number.to_i.Users
  @user.has_friendships(friends.map{|friend| {friend_id: friend.id} })
end

Then(/^I see (\d+) best studying people$/) do |number|
  expect(get_ids('top_person').count).to be number.to_i
end

Given(/^The following users exist$/) do |table|
  
  headers_keys  = {
                    'FIRST NAME'                       => :first_name,
                    'ROLE'                             => :role,
                    'LEVEL'                            => :level_number,
                    'CURRENT LESSON POSITION'          => :lesson_position,
                    'PASSED LESSON TEST ON'            => :test_passed_date
                  }   
  
  raw_data      = table.raw.to_hashes(headers_keys)
                  .change_hash_values(:level_number) do |number|
                    number.to_i
                  end  
                  .change_hash_values(:test_passed_date) do |date|
                    date.parse_date
                  end
  
  friends = []
  
  raw_data.each do |item|
    
    level = Level.where(number: item[:level_number]).first || FactoryGirl.create(:level, number: item[:level_number])
    lesson = Lesson.where(level_id: level.id, position: item[:lesson_position]).first || FactoryGirl.create(:lesson, level_id: level.id, position: item[:lesson_position])
    
    if item[:role] == 'myself'
      
      user = @user
      
    else
            
      user = FactoryGirl.create(:user, first_name: item[:first_name], test_passed_date: item[:test_passed_date] )
      friends.push(user) if item[:role] == 'myself'
      
    end
                  
    user.belongs_to(level).belongs_to_current_lesson(lesson)
      
  end
  
  @user.has_friendships(friends.map{|friend| {friend_id: friend.id} })
    
end

Then(/^I see best studying people sorted as following$/) do |table|  
    
  user_ids    =  get_ids('top_user')  
  user_names  =  table.raw.to_hashes('FIRST NAME' => :first_name ).map{|item| item[:first_name] }  
  user_ids.zip(user_names).each do |id, name|        
    user = User.find(id)  
    expect(user.first_name).to eq name if user.id != @user.id
  end  
  
end

Given(/^I have no friends$/) do
  @user.friendships.destroy_all
end

Then(/^I see link for me to invite friends$/) do
  has_link href: invite_path
end


