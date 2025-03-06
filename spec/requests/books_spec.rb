require 'rails_helper'

RSpec.describe BooksController, type: :request do
  let(:language) { create(:language) }
  let(:folder) { create(:folder) }
  let(:per_page) { 25 }
  let!(:books) { create_list(:book, 30, language: language, folder: folder) }

  before do
    allow(Settings.app).to receive(:items_per_page).and_return(per_page)
  end

  describe "GET /index" do
    it "returns http success" do
      get "/books/2"
      expect(json[:books].size).to eq(5)
    end

    it "returns http success" do
      get "/books"
      expect(json[:books].size).to eq(25)
    end
  end
end
