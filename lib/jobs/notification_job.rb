module Jobs
  class NotificationJob
    include Delayed::RecurringJob
    run_every 5.minutes
    priority 1
    def perform
      Notification.process
    end
  end
end
