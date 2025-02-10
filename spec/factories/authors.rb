FactoryBot.define do
  factory :author do
    first_name { FFaker::NameRU.first_name }
    last_name { FFaker::NameRU.last_name }
    books_count { 0 }
  end

  factory :invalid_author, parent: :author do
    first_name { nil }
    last_name { nil }
  end

  factory :full_author, parent: :author do
    middle_name { FFaker::NameRU.middle_name_male }
  end

  factory :author_with_books, parent: :author do
    books { [ association(:book) ] }
  end
end
