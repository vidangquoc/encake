# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :example do
    point_id { 0 }
    grammar_point_id { 0 }
    sequence(:content){ |n| "I love you #{n} times more than I can say" }
    sequence(:meaning){ |n| "Toi yeu em nhieu hon toi co the noi #{n} lan" }
    
    #factory :main_example do
    #  is_main true
    #end
    
  end
end
