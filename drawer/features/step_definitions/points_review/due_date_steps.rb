Given(/^I have the following points$/) do |table|
  
  @user = User.one.belongs_to(Level.one).belongs_to_current_lesson(Lesson.one)  
  
  headers_keys  = {
                    'POINT'                       => :content,                    
                    'EFFECTIVELY REVIEWED TIMES'  => :effectively_reviewed_times,
                    'DUE DATE'                    => :review_due_date                     
                  }   
  
  raw_data      = table.raw.to_hashes headers_keys
  
  user_points   = raw_data.extract_hashes(
                      :effectively_reviewed_times,
                      :review_due_date
                    )
                    .change_hash_values(:review_due_date) do |date|      
                      date.parse_date
                    end                  
  
  points        = raw_data.extract_hashes :content
  
  @user.has_user_points( user_points, :assoc ).belongs_to( Point.has(points), :assoc ).each_has_3_examples.belongs_to( points.count.Sounds(:factory) )
  
  choose_main_example_for_points
  
end
Given(/^I go to reviewing page$/) do
  signin @user
  visit points_review_path
end
Given(/^I get all of them for reviewing$/) do
  select 'number_of_points', 100
  click 'start_review'  
  ajax_complete?
end
When(/^I confirm that they has been reviewed$/) do  
  click 'finish_review'
  ajax_complete?
end

Then(/^They will be updated as the following$/) do |table|
  
  headers_keys  = {
                    'POINT'                       => :content,                    
                    'EFFECTIVELY REVIEWED TIMES'  => :effectively_reviewed_times,
                    'DUE DATE'                    => :review_due_date
                  }   
  
  raw_data      = table.raw.to_hashes(headers_keys)
                  .change_hash_values(:effectively_reviewed_times) do |times|
                    times.to_i
                  end  
                  .change_hash_values(:review_due_date) do |date|      
                    date.parse_date
                  end
  expect(  
  @user.user_points.includes(:point).map do |user_point|
    { :content => user_point.point.content,
      :effectively_reviewed_times => user_point.effectively_reviewed_times,
      :review_due_date => user_point.review_due_date
    }
  end).to eq raw_data
  
end