FactoryBot.define do
  factory :admin_user do
    email { FFaker::Internet.email }
    password { '321321' }
  end

  factory :invalid_admin_user, parent: :admin_user do
    email { nil }
    password { nil }
  end
end
