def load_yaml_for_me
  
  yaml_content = <<-YAML_CONTENT
  
    love:     
      meaning: yêu
      example:
        - I love you
        - Tôi yêu em
      question:
        - I __ you
        - love, loves, loved
        - love
        
    hate:      
      meaning: ghét
      example:
        - I hate you
        - Tôi ghét bạn
      question:
        - I __ you
        - hate, hates, hated
        - hate
        
  YAML_CONTENT

  YAML.load(yaml_content)
  
end