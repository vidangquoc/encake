User.all.each do |user|
  current_score = user.score
  user.score = user.calculate_score
  user.level = Level.get_level_for_score(user.score)
  if current_score != user.score
    puts user.email
    puts current_score
    puts user.score
    user.save!(validate: false)
  end
  
end.count