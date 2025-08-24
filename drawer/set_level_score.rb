highest_score = 0
delta = 0
Level.all.each do |level|
  case level.position
  when 1..5 then delta = 10
  when 6..10 then delta = 15
  when 11..15 then delta = 20
  when 16..20 then delta = 40
  when 21..25 then delta = 50
  when 26..50 then delta = 100
  else
    delta = 150
  end
  
  highest_score += delta
  level.update_attribute :highest_score, highest_score
end.count

User.all.each do |u|
  
  old_score = u.score
  old_level = u.level
  u.score = u.calculate_score
  u.level = Level.get_level_for_score(u.score)

  if old_score != u.score
    #u.save!(validate: false)
    puts("#{u.email} : ")
    puts("#{old_score} -> #{u.score}")
    puts("#{old_level.id} -> #{u.level.id}")
    puts("")
  end
  
end.count

current_score = 0
Level.all.each do |level|
  delta = level.highest_score - current_score
  puts delta if delta < 140 and level.id > 100
  current_score = level.highest_score
end

current_position = 0
Level.all.each do |level|
  delta = level.position - current_position
  puts delta
  current_position = level.position
end.count