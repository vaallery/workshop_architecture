FactoryBot.define do
  factory :book do
    title { FFaker::Book.title }
    libid { 3064 }
    size { 9836 }
    filename { 3064 }
    ext { 'fb2' }
    folder
    language
  end

  factory :invalid_book, parent: :book do
    title { nil }
    libid { nil }
    size { nil }
    filename { nil }
    folder
    language
  end

  factory :extract_book, parent: :book do
    folder { create(:folder, name: 'extract.zip') }
    language
  end

  factory :book_with_authors, parent: :book do
    folder { create(:folder, name: 'extract.zip') }
    authors { [ association(:author) ] }
    genres { [ association(:genre) ] }
    keywords { [ association(:keyword) ] }
  end
end
