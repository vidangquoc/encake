Given(/^My account exists$/) do
  @user = User.one.belongs_to(Level.one).belongs_to_current_lesson(Lesson.one) 
end
Given(/^I visit review page$/) do
  signin @user  
  visit points_review_path
end
Given(/^I have 20 points in my learning bag$/) do    
  @user.has_20_user_points(:assoc).belongs_to(20.Points, :assoc).each_has_3_examples.belongs_to( 20.Sounds(:factory) )
  choose_main_example_for_points  
end
When(/^I get (\d+) points for reviewing$/) do |number_of_points|
  select 'number_of_points', number_of_points
  click 'start_review'
  ajax_complete?
  @point_ids = get_point_ids
end
Then(/^I see a list of (\d+) points$/) do |number_of_points|
  expect(@point_ids.count).to eq number_of_points.to_i
end


Given(/^I have following points in my learning bag$/) do |table|
  
  headers_keys  = {
                    'POINT'                       => :content,
                    'NEXT REVIEWED DATE'          => :review_due_date,
                    'LAST REVIEWED DATE'          => :last_reviewed_date,
                    'EFFECTIVELY REVIEWED TIMES'  => :effectively_reviewed_times,
                    'REVIEWED TIMES'              => :reviewed_times                     
                  }   
  
  raw_data      = table.raw.to_hashes headers_keys
  
  user_points   = raw_data.extract_hashes(:review_due_date,
                                          :last_reviewed_date,
                                          :effectively_reviewed_times,
                                          :reviewed_times
                  )
                  .change_hash_values(:review_due_date) do |date|      
                    date.parse_date
                  end
                  .change_hash_values(:last_reviewed_date) do |date|                    
                    date.parse_date
                  end                            
  
  points        = raw_data.extract_hashes :content
  
  @user.has_user_points( user_points, :assoc ).belongs_to( Point.has(points), :assoc ).each_has_3_examples.belongs_to( points.count.Sounds(:factory) )
  
  choose_main_example_for_points
  
end
Then(/^I see the following points$/) do |table|   
  expect(@point_ids.sort).to eq @user.user_points.joins(:point).where( ['content in (?)', table.raw.flatten! ]).map(&:id).sort  
end



