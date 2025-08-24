def replace_for_file(file_path)  
  content = File.read(file_path)
  content = content.gsub(/^(\s*)(.*)\.should(\s)/, '\1expect(\2).to\3')
  content = content.gsub(/^(\s*)(.*)\.should_not(\s)/, '\1expect(\2).not_to\3')
  content = content.gsub(/^(\s*)(.*)\.any_instance\.should_receive/, '\1expect_any_instance_of(\2).to receive')
  content = content.gsub(/^(\s*)(.*)\.any_instance\.should_not_receive/, '\1expect_any_instance_of(\2).not_to receive')
  content = content.gsub(/^(\s*)(.*)\.should_receive/, '\1allow(\2).to receive')
  content = content.gsub(/\.to(\s)+(==)/, '.to eq')
  content = content.gsub(/\.not_to(\s)+(==)/, '.not_to eq')
  File.open(file_path, 'w') do |f|
    f.write(content)
  end
end

(Dir['spec/models/*'] + Dir['features/step_definitions/*'] + Dir['features/points_review/step_definitions/*']).each do |file_path|
 replace_for_file(file_path) if File.file?(file_path)
end
