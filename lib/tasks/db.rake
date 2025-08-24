# coding: UTF-8

namespace :db do
  
  namespace :dev do
    
    desc "Load test data to development database"
    
    task :load => :environment do
      
      ActiveRecord::Base.transaction do
        
        Administrator.one
        Administrator.one :factory=>:moderator            
        
        puts 'Finish creating admin users'
        
        5.Levels(:girl)
        
        puts "Finish creating levels"
                             
        5.Syllabuses.add_lessons 10.Lessons
        
        puts 'Finish creating syllabuses and lessons'
        
        Lesson.a.each_has_12_points.each_has_3_grammar_points.each_has_3_right_answer_explanations
        
        puts 'Finish creating points and grammar points'
        
        Point.a.make_sound{ |point, sound_attrs|
          sound_attrs[:for_content] = point.content
        }
        
        puts 'Finish creating sounds for points'
        
        Point.a.each_has_3_images(:girl)
        
        puts 'Finish creating images for points'
        
        Point.a.each_has_3_examples.each_has_4_questions
        
        Question.all.includes(:point => {:lesson => :right_answer_explanations}).each do |question|
          question.update_attribute :right_answer_explanation, question.point.lesson.right_answer_explanations.sample
        end
        
        puts 'Finish creating examples and questions'
                
        Point.a.make_main_example(factory: :example) do |point, example_attributes|
          example_attributes[:point_id] = point.id
          example_attributes[:is_main] = true
          example_attributes[:sound_id] = Sound.one(factory: [:sound, for_content: example_attributes[:content]]).id
        end
       
        puts 'Finish creating main examples for points'
        
        Example.a.each do |example|          
          example.belongs_to_grammar_point(example.point.lesson.grammar_points.sample)
        end
        
        puts 'Finish updating examples'
        
        Question.all.each do |question|
          question.send "has_#{rand(1..3)}_answers"
        end
               
        Question.a.make_right_answer(factory: :answer) do |question, answer_attributes|
          answer_attributes[:question_id] = question.id
          answer_attributes[:content] = 'Choose me!'
        end

        puts 'Finish creating answers'
        
        #create main test user             
        user = User.one(factory: [:user, email: 'dangquocvi@hotmail.com', user_type: 'new_change_eager'])
        #add friends
        friend1 = User.one(factory: [:user, email: 'dangquocvi@gmail.com'])
        friend2 = User.one(factory: [:user, email: 'laogiangongan@yahoo.com.vn'])        
        user.has_friendships([{friend_id: friend1.id}, {friend_id: friend2.id}] + 20.Users.map {|friend| {friend_id: friend.id} })
        
        puts 'Finish creating user'
               
        10.Invitations.each {|invitation| invitation.update_attribute :sender_id, User.second.id }
        
        puts 'Finish creating invitations'
                        
        10.FriendTeasers
        
        puts 'Finish creating friend teasers'
        
        BadgeType::BADGE_TYPES.each do |type|
          5.times do |n|
            FactoryBot.create :badge_type, badge_type: type, number_of_efforts_to_get: 500*(n + 1)
          end
        end
        
        puts 'Finish creating badge types'
      
      end
      
    end
       
  end
    
  namespace :test do
    
    desc "Clean test database"
    
    task :clean => :test do
      DatabaseCleaner.clean
    end
    
  end
  
end

namespace :db do

  namespace :dev do
    
    namespace :user do
    
      desc 'Clean data for test user'
      task clean_data: :environment do
        u = User.find_by email: 'dangquocvi@hotmail.com'
        u.taken_tests.destroy_all
        u.user_points.destroy_all
        u.update_attributes current_lesson_id: 1, level: Level.order('highest_score ASC').first, score: 0
      end
      
      desc 'Create due points for test user'
      task create_due_points: :environment do
        
        u = User.find_by email: 'dangquocvi@hotmail.com'
        u.user_points.destroy_all
        u.update_attribute :current_lesson_id, Lesson.first.id
        u.add_points_of_current_lesson
        u.user_points.update_all effectively_reviewed_times: 1, review_due_date: Date.today + 20.days, last_reviewed_date: Date.today - 2.days
        u.user_points.limit(2).update_all effectively_reviewed_times: 1, review_due_date: Date.today, last_reviewed_date: Date.today - 2.days
        
        first_level = Level.order('highest_score ASC').first
        u.score = first_level.highest_score - 3
        u.level = first_level
        u.save
        
        u.friends.first(2).serial_update score: [u.score + 1, u.score + 10]
        
      end
      
    end
    
    desc 'Clear user_event-related data'
    task clear_user_events_data: :environment do
      UserAction.delete_all
      UserEvent.delete_all
      Notification.delete_all
      PushNotification.delete_all
      Rpush::Gcm::Notification.delete_all
    end
    
    desc 'Show user event stats'
    task show_user_events_stats: :environment do
      puts "user actions: #{UserAction.count}"
      puts "user events: #{UserEvent.count}"
      puts "notifications: #{Notification.count}"
      puts "push notifications: #{PushNotification.count}"
      puts "rpush notifications: #{Rpush::Gcm::Notification.count}"
    end
    
  end
    
  desc "Clear failed delayed jobs that reach max attemps and older than one month"
  task clear_failed_jobs: :environment do
    BackgroundJob.delete_failed_jobs
  end
  
  desc "Clear application log table"
  task clear_app_logs: :environment do
    AppLog.delete_all
  end
  
  desc "Clear user ui actions that are older than one week"
  task clear_user_ui_actions: :environment do
    UserUiAction.where(['action_time < ?', (DateTime.now -1.week).strftime('%Q')]).delete_all
  end
  
  desc "Clear slow queries table"
  task clear_slow_queries: :environment do
    SlowQuery.delete_all
  end
  
  desc "Clear slow requests table"
  task clear_slow_requests: :environment do
    SlowRequest.delete_all
  end

  desc "Create db dump script"
  task create_db_dump_script: :environment do
    script = '';
    ActiveRecord::Base.connection.tables.map do |tbl|
      script += "mysqldump $ARGS #{tbl} > db/#{tbl}.db &&\n" if ActiveRecord::Base.connection.table_exists? tbl
    end
    puts script
  end
  
  namespace :rpush do
    
    desc "Create rpush apps"
    task create_apps: :environment do
      PushNotification.create_rpush_apps
    end
    
  end
    
end

namespace :cache do
    
  desc "Clear cache files"
  task clear: :environment do
    Cache::Cleaner.clear_index
    Cache::Cleaner.clear_point_types
  end
  
end
    
  
