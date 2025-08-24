Lesson.all.each do |lesson|
  changed = false
  content = Nokogiri::HTML.fragment(lesson.content)
  content.css("a").each do |node|
    if node['href'] =~ /^#(\/)+articles\//
      article_id = node['href'].match(/\d+/)[0].to_i
      puts "Found article##{article_id}"
      if article_id == 1
        article_id = 59
        node['x-article-id'] = article_id
        node['href'] = "#/articles/#{article_id}?show_back=true"
        changed = true
      end
    end
  end
  if changed
    puts "changed"
    lesson.update_attribute :content, content.to_html
  end
end