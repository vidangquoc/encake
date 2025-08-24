# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :user do
    first_name { "Vi" }
    middle_name { "Quoc " }
    last_name { "Dang" }    
    sequence(:email){ |n| "dangquocvi#{"_#{n}"}@hotmail.com" }
    password { "vidaica" }
    password_confirmation { "vidaica" }
    birthday_year { 1981 }
    birthday_month { 5 }
    birthday_day { 1 }
    gender { "male" }
    level_id { 0 }
    current_lesson_id { 0 }
    user_type { 'normal' }
    after(:build) do |user|
      user.status = User::STATUSES[:active] # for attribute that is not attr_accessible
    end
  end
end
