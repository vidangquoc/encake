require_relative '../spec_helper'

describe Metric do
  
  describe 'methods' do
    
    describe 'Class#avarage_first_session_lengths' do
      
      it 'calculates the avarage first session lengths correctly according to the time range' do
        
        #three months ago registrations
        start_of_3nd_month_ago = DateTime.now.beginning_of_month - 3.month
        
        #two months ago registrations
        start_of_2nd_month_ago = DateTime.now.beginning_of_month - 2.month
        user1, user2, user3, user4 = 4.Users(factory: [:user, created_at: start_of_2nd_month_ago])
        
        #last month registrations
        start_of_last_month = DateTime.now.beginning_of_month - 1.month
        user5, user6 = 2.Users(factory: [:user, created_at: start_of_last_month])
        
        #first sessions of users registered two months ago
        start_of_sessions = start_of_2nd_month_ago + 1.hours
        AuthenticationToken.one(factory: [:authentication_token,
                                                created_at: start_of_sessions, user_id: user1.id, user_type: 'active']
                                ).update_column :updated_at, start_of_sessions + 20.minutes
        
        AuthenticationToken.one(factory: [:authentication_token,
                                                created_at: start_of_sessions, user_id: user2.id, user_type: 'active']
                                ).update_column :updated_at, start_of_sessions + 30.minutes
        
        AuthenticationToken.one(factory: [:authentication_token,
                                                created_at: start_of_sessions, user_id: user3.id, user_type: 'active']
                                ).update_column :updated_at, start_of_sessions + 40.minutes
        
        #second sessions of users registered two months ago
        AuthenticationToken.one(factory: [:authentication_token, created_at: start_of_sessions + 5.days, user_id: user1.id, user_type: 'active'])
        AuthenticationToken.one(factory: [:authentication_token, created_at: start_of_sessions + 12.days, user_id: user2.id, user_type: 'active'])
        AuthenticationToken.one(factory: [:authentication_token, created_at: start_of_sessions + 10.days, user_id: user3.id, user_type: 'active'])
        
        #first sessions of users registered last month
        start_of_sessions = start_of_last_month + 1.days
        AuthenticationToken.one(factory: [:authentication_token,
                                          created_at: start_of_sessions, user_id: user5.id, user_type: 'active']
                                ).update_column :updated_at, start_of_sessions + 1.hour
        AuthenticationToken.one(factory: [:authentication_token,
                                          created_at: start_of_sessions, user_id: user6.id, user_type: 'active']
                                ).update_column :updated_at, start_of_sessions + 3.hours
        
        start_of_registering_time = start_of_3nd_month_ago
        end_of_registering_time = start_of_last_month.end_of_month
        
        first_session_length_metrics = Metric.avarage_first_session_lengths(start_of_registering_time, end_of_registering_time, :month)
        
        expect(first_session_length_metrics.count).to be 3
  
        metric_of_3nd_month_ago = first_session_length_metrics[0]
        metric_of_2nd_month_ago = first_session_length_metrics[1]
        metric_of_last_month = first_session_length_metrics[2]
        
        expect(metric_of_3nd_month_ago.start_time).to eq start_of_registering_time
        expect(metric_of_3nd_month_ago.end_time).to eq start_of_3nd_month_ago.end_of_month
        expect(metric_of_3nd_month_ago.avarage_first_session_length).to eq 0 # no data
        
        expect(metric_of_2nd_month_ago.start_time).to eq start_of_2nd_month_ago
        expect(metric_of_2nd_month_ago.end_time).to eq start_of_2nd_month_ago.end_of_month
        expect(metric_of_2nd_month_ago.avarage_first_session_length).to eq 30*60 # 30 minutes
        
        expect(metric_of_last_month.start_time).to eq start_of_last_month
        expect(metric_of_last_month.end_time).to eq end_of_registering_time
        expect(metric_of_last_month.avarage_first_session_length).to eq 2*60*60 # 2 hours
        
      end
        
    end
    
    describe 'Class#avarage_session_intervals' do
      
      it 'calculates the avarage session interval correctly according to the time range' do
        
        #three months ago registrations
        #no data
        start_of_3nd_month_ago = DateTime.now.beginning_of_month - 3.month
        
        #two months ago registrations
        start_of_2nd_month_ago = DateTime.now.beginning_of_month - 2.month
        user1, user2, user3, user4 = 4.Users(factory: [:user, created_at: start_of_2nd_month_ago])
        
        #last month registrations
        start_of_last_month = DateTime.now.beginning_of_month - 1.month
        user5, user6 = 2.Users(factory: [:user, created_at: start_of_last_month])
        
        #first sessions of users registered two months ago
        AuthenticationToken.one(factory: [:authentication_token, created_at: start_of_2nd_month_ago + 5.hours, user_id: user1.id, user_type: 'active'])
        AuthenticationToken.one(factory: [:authentication_token, created_at: start_of_2nd_month_ago + 15.hours, user_id: user2.id, user_type: 'active'])
        AuthenticationToken.one(factory: [:authentication_token, created_at: start_of_2nd_month_ago + 10.hours, user_id: user3.id, user_type: 'active'])
        
        #second sessions of users registered two months ago
        AuthenticationToken.one(factory: [:authentication_token, created_at: start_of_2nd_month_ago + 5.days, user_id: user1.id, user_type: 'active'])
        AuthenticationToken.one(factory: [:authentication_token, created_at: start_of_2nd_month_ago + 12.days, user_id: user2.id, user_type: 'active'])
        AuthenticationToken.one(factory: [:authentication_token, created_at: start_of_2nd_month_ago + 10.days, user_id: user3.id, user_type: 'active'])
        
        #first sessions of users registered last month
        AuthenticationToken.one(factory: [:authentication_token, created_at: start_of_last_month + 1.days, user_id: user5.id, user_type: 'active'])
        AuthenticationToken.one(factory: [:authentication_token, created_at: start_of_last_month + 3.days, user_id: user6.id, user_type: 'active'])
        
        start_of_registering_time = start_of_3nd_month_ago
        end_of_registering_time = start_of_last_month.end_of_month
        
        session_interval_metrics = Metric.avarage_session_intervals(start_of_registering_time, end_of_registering_time, :month)
        
        expect(session_interval_metrics.count).to be 3
  
        metric_of_3nd_month_ago = session_interval_metrics[0]
        metric_of_2nd_month_ago = session_interval_metrics[1]
        metric_of_last_month = session_interval_metrics[2]
        
        expect(metric_of_3nd_month_ago.start_time).to eq start_of_registering_time
        expect(metric_of_3nd_month_ago.end_time).to eq start_of_3nd_month_ago.end_of_month
        expect(metric_of_3nd_month_ago.avarage_session_interval).to eq 0 # no data
        
        expect(metric_of_2nd_month_ago.start_time).to eq start_of_2nd_month_ago
        expect(metric_of_2nd_month_ago.end_time).to eq start_of_2nd_month_ago.end_of_month
        expect(metric_of_2nd_month_ago.avarage_session_interval).to eq 10*60*60 # 10 hours
        
        expect(metric_of_last_month.start_time).to eq start_of_last_month
        expect(metric_of_last_month.end_time).to eq end_of_registering_time
        expect(metric_of_last_month.avarage_session_interval).to eq 2*24*60*60 # 2 days
        
      end
        
    end
    
    describe 'Class#retention_rates' do
      
      it 'calculates retention rates for targe set of users correctly according to the time range' do
        
        #two months ago registrations
        start_of_2nd_month_ago = DateTime.now.beginning_of_month - 2.month
        users = 10.Users(factory: [:user, created_at: start_of_2nd_month_ago + rand(28).day])
        
        #last month registrations
        start_of_last_month = DateTime.now.beginning_of_month - 1.month
        5.Users(factory: [:user, created_at: start_of_last_month + 1.day])
        
        #two week ago sessions
        start_of_2nd_week_ago = DateTime.now.beginning_of_week - 2.week
        AuthenticationToken.one(factory: [:authentication_token, user_type: 'anonymous',created_at: start_of_2nd_week_ago])
        AuthenticationToken.create_3(factory: [:authentication_token, user_id: users[0].id, user_type: 'active', created_at: start_of_2nd_week_ago + 10.hours])
        
        #last week sessions
        start_of_last_week = DateTime.now.beginning_of_week - 1.week
        #no data
        
        #this week sessions
        start_of_this_week = DateTime.now.beginning_of_week
        AuthenticationToken.one(factory: [:authentication_token, user_type: 'anonymous', created_at: start_of_this_week])
        (0..8).each do |index|
          AuthenticationToken.one(factory: [:authentication_token, user_id: users[index].id , user_type: 'active', created_at: start_of_this_week])
        end
        
        start_of_registering_time = start_of_2nd_month_ago
        end_of_registering_time = start_of_2nd_month_ago.end_of_month
        start_time = start_of_2nd_week_ago
        end_time = DateTime.now.end_of_day
        
        retention_rate_metrics = Metric.retention_rates(start_of_registering_time, end_of_registering_time, start_time, end_time, :week)
        
        expect(retention_rate_metrics.count).to be 3
        
        metric_of_2nd_week_ago = retention_rate_metrics[0]
        metric_of_last_week = retention_rate_metrics[1]
        metric_of_this_week = retention_rate_metrics[2]
        
        expect(metric_of_2nd_week_ago.start_time).to eq start_of_2nd_week_ago
        expect(metric_of_2nd_week_ago.end_time).to eq start_of_2nd_week_ago.end_of_week
        expect(metric_of_2nd_week_ago.retention_rate).to eq 10 # 3 active tokens, but only one user_id, 10 registrations
        
        expect(metric_of_last_week.start_time).to eq start_of_last_week
        expect(metric_of_last_week.end_time).to eq start_of_last_week.end_of_week
        expect(metric_of_last_week.retention_rate).to eq 0 # no data
        
        expect(metric_of_this_week.start_time).to eq start_of_this_week
        expect(metric_of_this_week.end_time).to eq end_time
        expect(metric_of_this_week.retention_rate).to eq 90 # 9 active tokens, 9 different user_id, 10 registrations
        
      end
        
    end
    
    describe 'Class#avarage_session_lengths' do
      
      it 'calculates avarage session lengths correctly according to the time range' do
        
        #this month
        start_of_this_month = DateTime.now.beginning_of_month
        AuthenticationToken.one(factory:[:authentication_token,
                                          user_type: 'anonymous',
                                          created_at: start_of_this_month,
                                        ]).update_column(:updated_at,  start_of_this_month + 1.days)
        
        AuthenticationToken.one(factory: [:authentication_token,
                                          user_type: 'active',
                                          created_at: start_of_this_month + 1.days,
                                         ]).update_column(:updated_at,  start_of_this_month + 1.days + 10.minutes)
        
        AuthenticationToken.one(factory: [:authentication_token,
                                          user_type: 'active',
                                          created_at: start_of_this_month + 1.days,
                                         ]).update_column(:updated_at,  start_of_this_month + 1.days + 30.minutes)
        #last month
        start_of_last_month = start_of_this_month - 1.month
        
        #two month ago
        start_of_2nd_month_ago = start_of_this_month - 2.month
        AuthenticationToken.one(factory: [:authentication_token,
                                          user_type: 'anonymous',
                                          created_at: start_of_2nd_month_ago,
                                         ]).update_column(:updated_at,  start_of_2nd_month_ago + 1.days)
        
        AuthenticationToken.one(factory: [:authentication_token,
                                            user_type: 'active',
                                            created_at: start_of_2nd_month_ago + 1.days,
                                          ]).update_column(:updated_at,  start_of_2nd_month_ago + 1.days + 2.hours)
        
        AuthenticationToken.one(factory: [:authentication_token,
                                          user_type: 'active',
                                          created_at: start_of_2nd_month_ago + 1.days,
                                         ]).update_column(:updated_at,  start_of_2nd_month_ago + 1.days + 4.hours)
        
        
        start_time = start_of_2nd_month_ago
        end_time = start_of_this_month.end_of_month
        
        avarage_session_length_metrics = Metric.avarage_session_lengths(start_time, end_time, :month)
        
        expect(avarage_session_length_metrics.count).to be 3
        
        metric_of_2nd_month_ago = avarage_session_length_metrics[0]
        metric_of_last_month = avarage_session_length_metrics[1]
        metric_of_this_month = avarage_session_length_metrics[2]
        
        expect(metric_of_2nd_month_ago.start_time).to eq start_of_2nd_month_ago
        expect(metric_of_2nd_month_ago.end_time).to eq start_of_2nd_month_ago.end_of_month
        expect(metric_of_2nd_month_ago.avarage_session_length).to eq 3*60*60 # 3 hours
        
        expect(metric_of_last_month.start_time).to eq start_of_last_month
        expect(metric_of_last_month.end_time).to eq start_of_last_month.end_of_month
        expect(metric_of_last_month.avarage_session_length).to eq 0 # 3 no data
        
        expect(metric_of_this_month.start_time).to eq start_of_this_month
        expect(metric_of_this_month.end_time).to eq start_of_this_month.end_of_month
        expect(metric_of_this_month.avarage_session_length).to eq 20*60 # 20 minutes
        
      end
        
    end
    
    describe 'Class#active_users' do
      
      it 'calculates active users correctly according to the time range' do
        
        #today
        start_of_today = DateTime.now.beginning_of_day
        AuthenticationToken.create_1(factory: [:authentication_token, user_type: 'anonymous', created_at: start_of_today])
        (1..9).each do |number|
          AuthenticationToken.create_1(factory: [:authentication_token, user_id: number, user_type: 'active', created_at: start_of_today])
        end
        
        #yesterday
        start_of_yesterday = start_of_today - 1.day
        AuthenticationToken.create_1(factory: [:authentication_token, user_type: 'anonymous',created_at: start_of_yesterday])
        (1..4).each do |number|
           AuthenticationToken.create_1(factory: [:authentication_token, user_id: number, user_type: 'active',created_at: start_of_yesterday.end_of_day])
        end
        
        #two days ago
        start_of_two_days_ago = start_of_today - 2.days
        #no data
        
        #three days ago
        start_of_three_days_ago = start_of_today - 3.days
        AuthenticationToken.create_1(factory: [:authentication_token, user_type: 'anonymous',created_at: start_of_three_days_ago])
        AuthenticationToken.create_3(factory: [:authentication_token, user_id: 1, user_type: 'active', created_at: start_of_three_days_ago + 10.hours])
        
        start_time = start_of_three_days_ago
        end_time = start_of_today.end_of_day
        
        daily_active_users_metrics = Metric.active_users(start_time, end_time, :day)
        
        expect(daily_active_users_metrics.count).to be 4
        
        metric_of_three_days_ago = daily_active_users_metrics[0]
        metric_of_two_days_ago = daily_active_users_metrics[1]
        metric_of_yesterday = daily_active_users_metrics[2]
        metric_of_today = daily_active_users_metrics[3]
        
        expect(metric_of_three_days_ago.start_time).to eq start_of_three_days_ago
        expect(metric_of_three_days_ago.end_time).to eq start_of_three_days_ago.end_of_day
        expect(metric_of_three_days_ago.active_users).to eq 1 # 3 active tokens, but only one user_id
        
        expect(metric_of_two_days_ago.start_time).to eq start_of_two_days_ago
        expect(metric_of_two_days_ago.end_time).to eq start_of_two_days_ago.end_of_day
        expect(metric_of_two_days_ago.active_users).to eq 0 # 3 no data
        
        expect(metric_of_yesterday.start_time).to eq start_of_yesterday
        expect(metric_of_yesterday.end_time).to eq start_of_yesterday.end_of_day
        expect(metric_of_yesterday.active_users).to eq 4 # 4 active tokens, 4 different user_id
        
        expect(metric_of_today.start_time).to eq start_of_today
        expect(metric_of_today.end_time).to eq start_of_today.end_of_day
        expect(metric_of_today.active_users).to eq 9 # 9 active tokens, 9 different user_id
        
      end
        
    end
    
    describe 'Class#conversion_rates' do
      
      it 'calculates the conversion rate correctly according to the time range' do
        
        #current week
        start_of_current_week = DateTime.now.beginning_of_week
        AuthenticationToken.create_1(factory: [:authentication_token, user_type: 'anonymous', created_at: start_of_current_week])
        AuthenticationToken.create_9(factory: [:authentication_token, user_type: 'just_registered', created_at: start_of_current_week + 2.seconds])
        
        #1st week ago
        start_of_1st_week_ago = start_of_current_week - 1.week
        AuthenticationToken.create_1(factory: [:authentication_token, user_type: 'anonymous',created_at: start_of_1st_week_ago])
        AuthenticationToken.create_4(factory: [:authentication_token, user_type: 'just_registered',created_at: start_of_1st_week_ago.end_of_week])
        
        #2nd week ago
        start_of_2nd_week_ago = start_of_current_week - 2.week
        AuthenticationToken.create_1(factory: [:authentication_token, user_type: 'anonymous',created_at: start_of_2nd_week_ago])
        AuthenticationToken.create_3(factory: [:authentication_token, user_type: 'just_registered', created_at: start_of_2nd_week_ago.end_of_week])
        
        #3rd week ago
        start_of_3rd_week_ago = start_of_current_week - 3.weeks
        #no data
        
        #4rd week ago
        start_of_4rd_week_ago = start_of_current_week - 4.weeks
        AuthenticationToken.create_1(factory: [:authentication_token, user_type: 'anonymous', created_at: start_of_4rd_week_ago])
        AuthenticationToken.create_1(factory: [:authentication_token, user_type: 'just_registered', created_at: start_of_4rd_week_ago.end_of_week])
        
        
        start_time = start_of_4rd_week_ago
        end_time = DateTime.now.end_of_week
        
        conversion_rates = Metric.conversion_rates(start_time, end_time)
        
        expect(conversion_rates.count).to be 5
        
        rate_of_4rd_week_ago = conversion_rates[0]
        rate_of_3rd_week_ago = conversion_rates[1]
        rate_of_2nd_week_ago = conversion_rates[2]
        rate_of_1st_week_ago = conversion_rates[3]
        rate_of_current_week = conversion_rates[4]
        
        expect(rate_of_4rd_week_ago.start_time).to eq start_of_4rd_week_ago
        expect(rate_of_4rd_week_ago.end_time).to eq start_of_4rd_week_ago.end_of_week
        expect(rate_of_4rd_week_ago.conversion_rate).to eq 50 #= (1/(1 + 1))*100
        
        expect(rate_of_3rd_week_ago.start_time).to eq start_of_3rd_week_ago
        expect(rate_of_3rd_week_ago.end_time).to eq start_of_3rd_week_ago.end_of_week
        expect(rate_of_3rd_week_ago.conversion_rate).to eq 0 #= no data
        
        expect(rate_of_2nd_week_ago.start_time).to eq start_of_2nd_week_ago
        expect(rate_of_2nd_week_ago.end_time).to eq start_of_2nd_week_ago.end_of_week
        expect(rate_of_2nd_week_ago.conversion_rate).to eq 75 #= (3/(3 + 1))*100
        
        expect(rate_of_1st_week_ago.start_time).to eq start_of_1st_week_ago
        expect(rate_of_1st_week_ago.end_time).to eq start_of_1st_week_ago.end_of_week
        expect(rate_of_1st_week_ago.conversion_rate).to eq 80 #= (4/(4 + 1))*100
        
        expect(rate_of_current_week.start_time).to eq start_of_current_week
        expect(rate_of_current_week.end_time).to eq start_of_current_week.end_of_week
        expect(rate_of_current_week.conversion_rate).to eq 90 #= (9/(9 + 1))*100
       
      end
        
    end
    
    describe 'Class#create_time_ranges' do
      
      context "interval is day" do
        
        before :each do
          @end_time = DateTime.now.beginning_of_day + 12.hours
          @start_time = @end_time - 10.days
        end
        
        it 'creates correct day ranges' do
          
          ranges = Metric.create_time_ranges(@start_time, @end_time, :day)
          
          expect(ranges.uniq.count).to eq 11
          
          ranges.each do |range|
            expect(range.first).to eq range.first.beginning_of_day
            expect(range.last).to eq range.last.end_of_day
          end
          
        end
        
      end
      
      context "interval is week" do
        
        before :each do
          @end_time = DateTime.now.beginning_of_day + 12.hours
          @start_time = @end_time.beginning_of_week - 3.weeks - 3.day
        end
        
        it 'creates correct week ranges' do
          
          ranges = Metric.create_time_ranges(@start_time, @end_time, :week)
          
          expect(ranges.count).to eq 5
          
          first_range = ranges.first
          expect(first_range.first).to eq @start_time
          expect(first_range.last.sunday?).to be true
          
          middle_ranges = ranges[1..3]
          middle_ranges.each do |middle_range|
            expect(middle_range.first.monday?).to be true
            expect(middle_range.last.sunday?).to be true
          end
          
          last_range = ranges.last
          expect(last_range.first.monday?).to be true
          expect(last_range.last).to eq @end_time
          
        end
        
      end
      
      context 'interval is month' do
        
        before :each do
          @start_time = DateTime.parse('2020-4-15 12:0:0')
          @end_time = DateTime.parse('2020-8-15 12:0:0')
        end
        
        it 'creates correct month ranges' do
          
          ranges = Metric.create_time_ranges(@start_time, @end_time, :month)
          
          expect(ranges).to eq [
            [@start_time, DateTime.parse('2020-4-30 23:59:59')],
            [DateTime.parse('2020-5-1 0:0:0'), DateTime.parse('2020-5-31 23:59:59')],
            [DateTime.parse('2020-6-1 0:0:0'), DateTime.parse('2020-6-30 23:59:59')],
            [DateTime.parse('2020-7-1 0:0:0'), DateTime.parse('2020-7-31 23:59:59')],
            [DateTime.parse('2020-8-1 0:0:0'), @end_time],
          ]
          
        end
        
      end
      
      it "raises an error if interval is invalid" do
        expect{Metric.create_time_ranges(DateTime.now, DateTime.now + 1.hours, :invalid)}.to raise_exception(Exception)
      end
      
    end
    
  end
  
end
