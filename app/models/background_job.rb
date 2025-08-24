class BackgroundJob < ActiveRecord::Base
  self.table_name = 'delayed_jobs'
  before_save :not_allow #do not allow creating and updating delayed_jobs via this class
  private
  def not_allow
    return false
  end
end

class << BackgroundJob
  def delete_failed_jobs
    where(['failed_at IS NOT NULL AND attempts >= ? AND failed_at < ?', Delayed::Worker.max_attempts, 1.month.ago]).delete_all
  end
end