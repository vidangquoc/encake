module Jobs
  class RpushJob
    include Delayed::RecurringJob
    run_every 5.minutes
    priority 1
    def perform
      Rpush.push
      Rpush.apns_feedback
    end
  end
end
