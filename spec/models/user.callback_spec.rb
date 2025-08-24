#encoding: utf-8

require_relative '../spec_helper'

describe User do
  
  context 'before create' do
      
    before :each do
      @user = FactoryBot.build :user
    end
    
    it 'set level to the first level' do
      1.Level       
      @user.save!
      expect(@user.level.id).to be Level.order('highest_score ASC').first.id
    end
    
    it 'set current lesson to the first lesson' do
      1.Lesson       
      @user.save!
      expect(@user.current_lesson.id).to be Lesson.first.id
    end
    
  end
  
end