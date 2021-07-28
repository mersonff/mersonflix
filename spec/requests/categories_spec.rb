require 'rails_helper'

describe 'GET all categories route', type: :request do
  before do
    @category = Category.create(title: "LIVRE", color: "BRANCO")
    9.times do
      @category = Category.create(title: "Comédia", color: "Azul")
    end
  end

  describe 'GET categories#index' do
    context 'with persisted categories' do
      before do
        get '/categories'
      end
      it 'return the list of persisted categories' do
        json = JSON.parse(response.body)
        expect(json.size).to eq(10)
      end
      it 'return :success status' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end

describe 'POST categories#create' do
  context 'with valid attributes' do
    before do
      @category = Category.create(title: "LIVRE", color: "BRANCO")
    end
    it 'create categorie and return :created status' do
      category_params = {
        category: {
          title: 'Comédia',
          color: 'Azul'
        }
      }
      post '/categories', params: category_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq('Comédia')
      expect(json['id']).to_not eq(1)
      expect(response).to have_http_status(:created)
    end
  end

  context 'with valid attributes but not LIVRE with id 1' do
    it 'create categorie and return :created status' do
      category_params = {
        category: {
          title: 'Comédia',
          color: 'Azul'
        }
      }
      post '/categories', params: category_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq(["first category should be LIVRE"])
      expect(json['id']).to_not eq(1)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context 'with invalid attributes' do
    before do
      @category = Category.create(title: "LIVRE", color: "BRANCO")
    end
    it 'do not create the categorie and return :unproccessable_entity status' do
      category_params = {
        category: {
          title: '',
          color: ''
        }
      }
      post '/categories', params: category_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq(["can't be blank"])
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end