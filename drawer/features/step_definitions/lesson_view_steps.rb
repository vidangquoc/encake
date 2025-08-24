Given(/^A lesson exists$/) do
  #context
  @lesson = Lesson.one
  #@category1, @category2 = Category.create_2
  @point1, @point2, @point3, @point4 = @lesson.has_4_points(:assoc)
  #@category1.add_points [@point1, @point3]
  #@category2.add_points [@point2, @point4]  
end
And(/^I view the lesson$/) do
  visit lesson_path(@lesson)
end

Then(/^I see content of the lesson$/) do
  expect(page).to have_css("#lesson_content")
end
Then(/^I see lists of points grouped in categories$/) do
    
  expect(page).to have_css("#category_#{@category1.id} #point_#{@point1.id}")
  expect(page).to have_css("#category_#{@category1.id} #point_#{@point3.id}")
  
  expect(page).to have_css("#category_#{@category2.id} #point_#{@point2.id}")
  expect(page).to have_css("#category_#{@category2.id} #point_#{@point4.id}")
  
end
Then(/^Categories are sorted by their pre\-defined positions in accending order$/) do
  expect(get_ids('category')).to eq [@category1, @category2].sort_by(&:position).map(&:id)  
end

Given(/^Content of the lesson contains several occurences of \[\[\[ and \]\]\] with text in them$/) do
  content = <<-CONTENT
    Content contains
    [[[
      First line of group 1
      Second line of group 1
    ]]]
    This is a line between two groups
    [[[
      First line of group 2
      Second line of group 2
    ]]]
  CONTENT
  @lesson.update_attribute :content, content
end
Then(/^I don't see the content between the occurences of \[\[\[ and \]\]\] in lesson content$/) do
  expect(page).not_to have_text(/\[{3}.*\]{3}/m)
  expect(page).to have_text('This is a line between two groups')
end

Given(/^Some category has no points$/) do
  @category2.points.destroy_all
end
Then(/^I don't see that category listed$/) do
  expect(page).not_to have_css("#category_#{@category2.id}")
end

Given(/^The lesson has a associated video$/) do
  @lesson.update_attribute :video_url, "http://mysite.com/some_video"
end
Then(/^I see the video$/) do
  expect(page).to have_css("#lesson_video")
end

Given(/^The lesson do not have associated video$/) do
   @lesson.update_attribute :video_url, nil
end
Then(/^I do not see any video$/) do
  expect(page).not_to have_css("#lesson_video")
end


Given(/^I have already signed in$/) do
  @user = User.one.belongs_to(Level.one).belongs_to_current_lesson(Lesson.one) 
  signin @user
end
Given(/^The lesson is my current lesson$/) do
  @user.current_lesson = @lesson
  @user.save
end
Then(/^I see a link for me to take test$/) do
  has_link href: test_path
end

Given(/^The lesson is not my current lesson$/) do
  @user.current_lesson = Lesson.one
  @user.save
end
Then(/^I don't see a link for me to take test$/) do
  not_have_link href: test_path
end
