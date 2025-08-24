Lesson.all.each do |lesson|
  content = Nokogiri::HTML.fragment(lesson.content)
  content.css("a").each do |node|
    if node['href'] =~ /^#(\/)+articles\//
      article_id = node['href'].match(/\d+/)[0].to_i
      node['x-article-link'] = ''
      node['x-article-id'] = article_id
      node['class'] = 'article_link'
      node['href'] = "#/articles/#{article_id}?show_back=true"
      node.delete('target')
    end
  end
  lesson.update_attribute :content, content.to_html
end


