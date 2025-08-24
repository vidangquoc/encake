json.around_levels @around_levels
json.score current_user.score
json.due_points @number_of_due_points
json.total_points @number_of_learnt_points
json.points @points, partial: 'api/points/point', as: :point
json.mode @mode