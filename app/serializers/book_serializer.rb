# frozen_string_literal: true

class BookSerializer
  include Alba::Resource
  root_key!

  attributes :id, :title
end
