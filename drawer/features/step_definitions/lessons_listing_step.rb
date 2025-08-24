Given(/^I visit lesson listing page$/) do
    
  9.Lessons.belongs_to 3.Levels
  
  Level.first.update_attribute(:number, Level.last.number + 1)
  
  Level.all.each {|level| level.lessons.last.move_higher  } # change lesson position
    
  Lesson.first.update_attribute :active, false
  Lesson.last.update_attribute :active, false
  
  @user = User.one.belongs_to_current_lesson(Level.second.lessons.first)
   
  signin @user
    
  visit lessons_path
  
end

Then(/^I see lessons are grouped into their corresponding levels$/) do
  
  lessons = get_previous_active_lessons.includes(:level)
    
  lessons.each do |lesson|
    
    expect(page).to have_css("#level_#{lesson.level.id} #lesson_#{lesson.id}")
    
  end
  
end

Then(/^The lessons are sorted ascendingly according to their positions$/) do
  
  Level.where(['number <= ?', @user.current_lesson.level.number]).each do |level|
    
    conditions = level.number < @user.current_lesson.level.number ? ['active=?', true] : ['active=? AND position <= ?', true, @user.current_lesson.position]
    
    expected_lesson_ids = level.lessons.where(conditions).order('position asc').map { |lesson| lesson.id }
      
    lesson_ids_on_page = page.all("#level_#{level.id} .lesson").map{|element| element['data-id'] }.map(&:to_i)
        
    expect(lesson_ids_on_page).to eq expected_lesson_ids
    
  end
    
end

Then(/^The levels are also sorted ascendingly according to their positions$/) do
  expect(get_ids('level')).to eq Level.where(['number <= ?', @user.current_lesson.level.number]).order('number asc').map(&:id)
end

Then(/^I see a list of all active lessions that less than my current lesson$/) do
  expect(get_ids('lesson').sort).to eq get_previous_active_lessons.map(&:id).sort
end

def get_previous_active_lessons
  Lesson.joins(:level).where(['lessons.active= ? and lessons.position <= ? and levels.number <= ?', true, @user.current_lesson.position, @user.current_lesson.level.number])
end

