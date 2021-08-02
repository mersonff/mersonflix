require 'rails_helper'

describe 'GET all videos route', type: :request do
  before do
    @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
    login(@john)
    @auth_params = get_auth_params_from_login_response_headers(response)
    @category = Category.create(title: "LIVRE", color: "BRANCO")
    10.times do
      @video = Video.create(title: "O vento levou", description: "Loren Ipsum", url: "http://www.teste.com", category: @category)
    end
  end

  context 'with persisted videos' do
    before do
      get '/videos', headers: @auth_params
    end
    it 'return the list of persisted videos' do
      expect(JSON.parse(response.body).size).to eq(5)
    end
    it 'return :success status' do
      expect(response).to have_http_status(:success)
    end
  end
end

describe 'POST videos#create', type: :request do
  before do
    @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
    login(@john)
    @auth_params = get_auth_params_from_login_response_headers(response)
    @category = Category.create(title: "LIVRE", color: "BRANCO")
  end
  context 'with valid attributes' do
    it 'create video and return :created status' do
      video_params = {
        video: {
          title: 'RED',
          description: 'Lorem Ipsum',
          url: 'http://www.teste.com/video',
          category_id: @category.id
        }
      }
      post '/videos', params: video_params, headers: @auth_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq('RED')
      expect(response).to have_http_status(:created)
    end
  end

  context 'with invalid attributes' do
    it 'not create the video and return :unproccessable_entity status' do
      video_params = {
        video: {
          title: '',
          description: '',
          url: '',
          category_id: @category.id
        }
      }
      post '/videos', params: video_params, headers: @auth_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq(["can't be blank"])
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

describe 'GET videos#show', type: :request do
  before do
    @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
    login(@john)
    @auth_params = get_auth_params_from_login_response_headers(response)
    @category = Category.create(title: "LIVRE", color: "BRANCO")
    @video = Video.create(title: "O vento levou", description: "Loren Ipsum", url: "http://www.teste.com", category: @category)
  end
  context 'with existing id' do
    it 'return the video data and :ok status' do
      get "/videos/#{@video.id}", headers: @auth_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq('O vento levou')
      expect(response).to have_http_status(:ok)
    end
  end

  context 'with non existing id' do
    id = 0
    it 'returns 404 record not found' do
      get "/videos/#{id}", headers: @auth_params
      expect(response).to have_http_status(:not_found)
      expect(response.body).to eq( "{\"error\":\"Couldn't find Video with 'id'=0\"}")
    end
  end
end

describe 'PUT videos#update', type: :request do
  before do
    @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
    login(@john)
    @auth_params = get_auth_params_from_login_response_headers(response)
    @category = Category.create(title: "LIVRE", color: "BRANCO")
  end

  context 'with valid attributes' do
    it 'update the video and return :ok status' do
      video_params = {
        video: {
          title: 'RED',
          description: 'Lorem Ipsum',
          url: 'http://www.teste.com/video',
          category_id: @category.id
        }
      }

      new_video_params = {
        video: {
          title: 'RED 2',
          description: 'Lorem Ipsum 2',
          url: 'http://www.teste.com/video2'
        }
      }
      video = Video.create(video_params[:video])
      put "/videos/#{video.id}", params: new_video_params, headers: @auth_params
      json = JSON.parse(response.body)
      expect(json["description"]).to include("Lorem Ipsum 2")
      expect(response).to have_http_status(:ok)
    end
  end

  context 'with invalid attributes' do
    it 'do not update the video and return :unproccessable_status' do
      video_params = {
        video: {
          title: 'RED',
          description: 'Lorem Ipsum',
          url: 'http://www.teste.com/video',
          category_id: @category.id
        }
      }

      new_video_params = {
        video: {
          title: '',
          description: 'Lorem Ipsum 2',
          url: 'http://www.teste.com/video2',
          category: @category
        }
      }

      video = Video.create(video_params[:video])
      put "/videos/#{video.id}", params: new_video_params, headers: @auth_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq(["can't be blank"])
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

describe 'DELETE videos#delete', type: :request do
  before do
    @john = User.create(email: "test@test.com", password: 12345678, password_confirmation: 12345678)
    login(@john)
    @auth_params = get_auth_params_from_login_response_headers(response)
    @category = Category.create(title: "LIVRE", color: "BRANCO")
  end
  it 'delete the video and return no_content status' do
    video_params = {
      video: {
        title: 'RED',
        description: 'Lorem Ipsum',
        url: 'http://www.teste.com/video',
        category_id: @category.id
      }
    }
    video = Video.create(video_params[:video])
    delete "/videos/#{video.id}", headers: @auth_params
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

