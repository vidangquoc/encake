FactoryBot.define do
  
  factory :admin_user do
    
    first_name { 'Vi' }
    last_name { 'Dang' }
    email { 'dangquocvi@gmail.com' }
    role { 'admin' }
    password { 'vidaica' }
    status { true }
        
    factory :editor_admin_user do
      email { 'nhucam@gmail.com' }
      role { 'editor' }
    end    
    
  end
  
end