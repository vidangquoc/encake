Given(/I am on point review page/) do
    
  @user = User.one
  @user.has_10_user_points(:assoc).belongs_to(10.Points, :assoc).each_has_3_examples.belongs_to( 10.Sounds(:factory) )
  @user.belongs_to(Level.one).belongs_to_current_lesson Lesson.one
  choose_main_example_for_points
  signin @user
  visit points_review_path
  
end
And(/^I choose English to Vietnamease as review mode$/) do  
  check_bootstrap_button 'review_mode_en_vi'
end
And(/^I get (\d+) points for review$/) do |number_of_points|
  puts number_of_points
  select 'number_of_points', number_of_points 
  click 'start_review'
  ajax_complete?
  @point_ids = get_point_ids
end


Then(/^Content of the current point is shown as title of reminding box$/) do
  expect(get_text("remind_title")).to eq Point.find( get_id 'current_point').content
end
Then(/^Meaning of the current point is shown as content of reminding box$/) do
  expect(get_text("remind_content")).to eq Point.find( get_id 'current_point' ).meaning
end


Given(/^I am in the midle of the point list$/) do
  3.times{ click "next_point" }
end


When(/^I click to hear sound of current point$/) do
  @user_point = @user.user_points.where(:point_id => get_id('current_point') ).first  
  click "listen_sound"
end
Then(/^I am not considered to get reminding on the current point$/) do
  click 'finish_review'
  @user_point_refresh = UserPoint.find( @user_point.id )
  expect(@user_point_refresh.reminded_times).to eq @user_point.reminded_times
end


Given(/^If some points are reminded on current turn, on next turned only reminded points are displayed$/) do |table|
  
  headers_keys = {
    'TURN'             => :turn,
    'DISPLAYED POINTS' => :displayed_points,
    'REMINDED POINTS'  => :remindeds_points
  }
  
  table = table.raw.to_hashes headers_keys
  
  table.each do |row|
    turn = row[:turn].to_i
    displayed_points = row[:displayed_points].split(',').map(&:to_i)
    reminded_points = row[:remindeds_points].split(',').map(&:to_i)
        
    if turn == 1     
      click "remind" if reminded_points.include?( get_id 'current_point' )     
      (displayed_points.count - 1).times do
        click 'next_point'       
        click "remind" if reminded_points.include?( get_id 'current_point' )
      end  
    else
      
      displayed_points.count.times do
        click 'next_point'       
        expect(displayed_points.include?(get_id 'current_point')).to be true
        click "remind" if reminded_points.include?( get_id 'current_point' )
      end  
    end
    
  end
  
end


Given(/^Some points on current turn are reminded$/) do
  @reminded_point_ids = []
  (@point_ids.count-1).times do
    click 'next_point'
    if [true, false].sample
      click "remind"
      @reminded_point_ids << get_id("current_point")
    end  
  end  
end
Then(/^On the next turn, when I click to see previous point, only reminded points are displayed$/) do  
  @reminded_point_ids.count.times do
    click 'next_point'
  end
  @reminded_point_ids.count.times do
    click 'previous_point'
    expect(@reminded_point_ids.include?(get_id "current_point" )).to be true
  end
end


Then(/^On next turn, I try to click back to current turn$/) do
  2.times { click 'next_point' }
  3.times { click 'previous_point' }    
end
Then(/^I can only reach to the first point of the next turn$/) do
  expect(get_id("current_point")).to eq @reminded_point_ids.first
end


When(/^I confirm that I have finished reviewing$/) do
  click 'finish_review'
  ajax_complete?
end
Then(/^I see that point list is empty$/) do
  expect(get_ids('reviewed_point')).to be_empty
end
Then(/^I see that point screen is empty$/) do
  expect(get_text("current_point")).to eq ''  
end


When(/^I switch review mode to "Vietnamease to English"$/) do  
  check_bootstrap_button 'review_mode_vi_en'
end


And(/^I choose Vietnamease to English as review mode$/) do  
  check_bootstrap_button 'review_mode_vi_en'  
end


When(/^I get reminding for the current point$/) do
  click 'remind'
end


Then(/^I am considered to get reminding on the current point$/) do  
  @user_point_refresh = UserPoint.find( @user_point.id )  
  expect(( @user_point_refresh.reminded_times  - @user_point.reminded_times )).to eq 1
end


When(/^I switch review mode to "English to Vietnamease"$/) do  
  check_bootstrap_button 'review_mode_en_vi'
end


Then(/^Content of the main example of the first point is shown on display screen$/) do
  expect(get_text "current_point").to eq Point.find( @point_ids.first ).main_example.content
end


Then(/^I don't hear any sound of the first point$/) do
  Log.manual_check "In English To Vietnamease mode and Learn By Example method, sound should not be played when the first point is displayed "
end

When(/^I move to the next point$/) do
  click "next_point"
end
Then(/^Content of the main example of the next point is shown on display screen$/) do 
  expect(get_text("current_point")).to eq Point.find( @point_ids[1] ).main_example.content 
end
Then(/^I hear sound of the main example of the next point$/) do
  Log.manual_check "In English To Vietnamease mode and Learn By Example method, sound of the main example should be played when moving to next point"
end


When(/^I move back to the previous point$/) do
   click "previous_point" 
end
Then(/^Content of the main example of the previous point is shown on display screen$/) do
  expect(get_text("current_point")).to eq Point.find( @point_ids[2] ).main_example.content 
end
Then(/^I hear sound of the main example of the previous point$/) do
  Log.manual_check "In English To Vietnamease mode and Learn By Example method, sound of the main example should be played when moving to previous point"
end


Then(/^Content of the main example of the point is shown on display screen$/) do  
  expect(get_text("current_point")).to be_include(Point.find(@point_ids[0]).main_example.content)
end
Then(/^Meaning of the main example of the point is also shown on display screen$/) do
  expect(get_text("current_point")).to be_include(Point.find(@point_ids[0]).main_example.meaning)
end


Then(/^I hear sound of the main example of the current point$/) do
  Log.manual_check "In English To Vietnamease mode and Learn By Example method, sound of the main example should be played when user click to listen to sound of the current point"
end


Then(/^Meaning of the main example of the curren point is shown on point screen$/) do
  expect(get_text("current_point")).to eq Point.find( get_id("current_point") ).main_example.meaning
end


Then(/^Meaning of the main example of the first point is shown on display screen$/) do
  expect(get_text("current_point")).to eq Point.find( @point_ids.first ).main_example.meaning
end


Then(/^Meaning of the main example of the next point is shown on display screen$/) do
  expect(get_text("current_point")).to eq Point.find(@point_ids[1]).main_example.meaning  
end
Then(/^I don't hear any sound of the next point$/) do
  Log.manual_check "Learn By Example method and Vietnamease To English mode, sound should not be played when moving to next point"
end


Then(/^Meaning of the main example of the previous point is shown on display screen$/) do
  expect(get_text("current_point")).to eq Point.find( @point_ids[2] ).main_example.meaning  
end
Then(/^I don't hear any sound of the previous point$/) do
  Log.manual_check "Learn By Example method and Vietnamease To English mode, sound should not be played when moving back to previous point"
end


Then(/^Content of the main example of the curren point is shown on display screen$/) do
  expect(get_text("current_point")).to eq Point.find( get_id "current_point" ).main_example.content
end

