require 'rails_helper'

describe 'GET all categories route', type: :request do
  before do
    @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
    login(@john)
    @auth_params = get_auth_params_from_login_response_headers(response)
    @category = Category.create(title: "LIVRE", color: "BRANCO")
    9.times do
      @category = Category.create(title: "Comédia", color: "Azul")
    end
  end

  context 'with persisted categories' do
    before do
      get '/categories', headers: @auth_params
    end
    it 'return the list of persisted categories' do
      json = JSON.parse(response.body)
      expect(json.size).to eq(5)
    end
    it 'return :success status' do
      expect(response).to have_http_status(:success)
    end
  end
end


describe 'POST categories#create' do
  context 'with valid attributes' do
    before do
      @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
      login(@john)
      @auth_params = get_auth_params_from_login_response_headers(response)
      @category = Category.create(title: "LIVRE", color: "BRANCO")
    end

    it 'create categorie and return :created status' do
      category_params = {
        category: {
          title: 'Comédia',
          color: 'Azul'
        }
      }
      post '/categories', params: category_params, headers: @auth_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq('Comédia')
      expect(json['id']).to_not eq(1)
      expect(response).to have_http_status(:created)
    end
  end

  context 'with valid attributes but not LIVRE with id 1' do
    before do
      @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
      login(@john)
      @auth_params = get_auth_params_from_login_response_headers(response)
    end
    it 'create categorie and return :created status' do
      category_params = {
        category: {
          title: 'Comédia',
          color: 'Azul'
        }
      }
      post '/categories', params: category_params, headers: @auth_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq(["first category should be LIVRE"])
      expect(json['id']).to_not eq(1)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  context 'with invalid attributes' do
    before do
      @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
      login(@john)
      @auth_params = get_auth_params_from_login_response_headers(response)
      @category = Category.create(title: "LIVRE", color: "BRANCO")
    end
    it 'do not create the categorie and return :unproccessable_entity status' do
      category_params = {
        category: {
          title: '',
          color: ''
        }
      }
      post '/categories', params: category_params, headers: @auth_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq(["can't be blank"])
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

describe 'GET categories#show' do
  before do
    @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
    login(@john)
    @auth_params = get_auth_params_from_login_response_headers(response)
    @category = Category.create(title: "LIVRE", color: "BRANCO")
  end
  context 'with existing id' do
    it 'return the category data and :ok status' do
      get "/categories/#{@category.id}", headers: @auth_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq('LIVRE')
      expect(response).to have_http_status(:ok)
    end
  end

  context 'with non existing id' do
    id = 0
    it 'returns 404 record not found' do
      get "/categories/#{id}", headers: @auth_params
      expect(response).to have_http_status(:not_found)
      expect(response.body).to eq( "{\"error\":\"Couldn't find Category with 'id'=0\"}")
    end
  end
end

describe 'PUT categories#update' do
  before do
    @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
    login(@john)
    @auth_params = get_auth_params_from_login_response_headers(response)
    @category = Category.create(title: "LIVRE", color: "BRANCO")
  end
  context 'with valid attributes' do
    it 'update the category and return :ok status' do
      category_params = {
        category: {
          title: 'Ação',
          color: 'AZUL'
        }
      }

      new_category_params = {
        category: {
          title: 'Açãozaço',
          color: 'PRETO'
        }
      }
      category = Category.create(category_params[:category])
      put "/categories/#{category.id}", params: new_category_params, headers: @auth_params
      json = JSON.parse(response.body)
      expect(json["title"]).to include("Açãozaço")
      expect(json["color"]).to include("PRETO")
      expect(response).to have_http_status(:ok)
    end
  end
end

describe 'DELETE categories#delete' do
  before do
    @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
    login(@john)
    @auth_params = get_auth_params_from_login_response_headers(response)
    @category = Category.create(title: "LIVRE", color: "BRANCO")
  end
  it 'delete the category and return no_content status' do
    category_params = {
      category: {
        title: 'RED',
        color: 'Lorem Ipsum'
      }
    }
    category = Category.create(category_params[:category])
    delete "/categories/#{category.id}", headers: @auth_params
    expect(response.status).to eq(204)
  end

end

def login(user)
  post '/auth/sign_in', params:  { email: user.email, password: user.password }.to_json, headers: { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' }
end

def get_auth_params_from_login_response_headers(response)
  client = response.headers['client']
  token = response.headers['access-token']
  expiry = response.headers['expiry']
  token_type = response.headers['token-type']
  uid = response.headers['uid']

  auth_params = {
    'access-token' => token,
    'client' => client,
    'uid' => uid,
    'expiry' => expiry,
    'token-type' => token_type
  }
  auth_params
end
