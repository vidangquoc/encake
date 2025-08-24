Lesson.all.each do |lesson|
  changed = false
  content = Nokogiri::HTML.fragment(lesson.content)
  content.css("span.translator").each do |node|
    if !node['title'].blank?
      node['x-title'] = node['title']
      node.delete('title')
      changed = true
      puts "changed for #{lesson.id}"
    end
  end
  if changed
    puts "update lessons #{lesson.id}"
    lesson.update_attribute :content, content.to_html
  end
end.count