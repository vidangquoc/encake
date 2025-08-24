def alter_lessons_content
  Lesson.find_each do |lesson|
    doc = Nokogiri::HTML::DocumentFragment.parse(lesson.content)
    doc.css("span.translator").each do |node|   
      node['title'] = node['data-content']
      node.attributes["data-content"].remove if !node.attributes["data-content"].nil?
      node.delete('data-content')
    end
    lesson.update content: doc.to_s
  end
end

alter_lessons_content