FactoryBot.define do
  factory :genre do
    slug { FFaker::Internet.slug }
    name { FFaker::Book.genre }
    genre_group
  end

  factory :invalid_genre, parent: :genre do
    slug { nil }
    name { nil }
    genre_group
  end
end
