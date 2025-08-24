FactoryBot.define do
  factory :common_word_meaning do
    common_word_id { 1 }
content { "MyString" }
word_type { "MyString" }
meaning { "MyString" }
selected { false }
  end

end
