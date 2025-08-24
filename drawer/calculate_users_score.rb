def calculate_users_score
  User.all.each do |user|
    user.score = user.calculate_score
    user.level = Level.get_level_for_score(user.score)
    user.save
  end
end