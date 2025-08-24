FactoryBot.define do
  
  factory :syllabus do
    
    sequence(:syllabus_order){|n| n}
    
    sequence(:name){|n| "Syllabus #{n}" }
        
    factory :another_syllabus do
    end
    
    factory :invalid_syllabus do
      name { "" }
    end
  
  end

end
