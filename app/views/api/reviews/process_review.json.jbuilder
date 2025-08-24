json.mode @mode
json.around_levels @around_levels
json.score current_user.score
json.due_points @number_of_due_points
json.learnt_points @number_of_learnt_points
json.points @points, partial: 'api/points/point', as: :point
json.process_review_result do
  json.extract! @process_review_result, :score_change, :level_changed, :overcome_friends, :action_id, :number_of_rewarded_lucky_stars
  json.lucky_star_image asset_path('lucky_star.png')
  json.opportunity do
    if @process_review_result[:opportunity]
      json.extract! @process_review_result[:opportunity], :id, :user_id, :is_taken
      json.badge_type do
        json.extract! @process_review_result[:opportunity].badge_type, :id, :badge_type, :name, :number_of_efforts_to_get
        json.image_url @process_review_result[:opportunity].badge_type.image.url
      end
      json.next_badge_type @process_review_result[:opportunity].badge_type.next_badge_type
      json.min_opportunity_possibility Constants.min_opportunity_possibility
      json.max_opportunity_possibility Constants.max_opportunity_possibility
      json.processing_image asset_path('opportunity_processing.gif')
      json.number_of_lucky_stars Badge.count_lucky_stars_for_user(current_user.id)
    else
      json.nil!
    end
  end
end