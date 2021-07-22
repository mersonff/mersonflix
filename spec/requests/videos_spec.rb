require 'rails_helper'

describe 'GET all videos route', type: :request do
  before do
    10.times do
      @video = Video.create(title: "O vento levou", description: "Loren Ipsum", url: "http://www.teste.com")
    end
  end

  describe 'GET videos#index' do
    context 'with persisted videos' do
      before do
        get '/videos'
      end
      it 'return the list of persisted videos' do
        expect(JSON.parse(response.body).size).to eq(10)
      end
      it 'return :success status' do
        expect(response).to have_http_status(:success)
      end
    end
  end
end

describe 'POST videos#create' do
  context 'with valid attributes' do
    it 'create video and return :created status' do
      video_params = {
        video: {
          title: 'RED',
          description: 'Lorem Ipsum',
          url: 'http://www.teste.com/video'
        }
      }
      post '/videos', params: video_params
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
          url: ''
        }
      }
      post '/videos', params: video_params
      json = JSON.parse(response.body)
      expect(json['title']).to eq(["can't be blank"])
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end

describe 'GET videos#show' do
  before do
    @video = Video.create(title: "O vento levou", description: "Loren Ipsum", url: "http://www.teste.com")
  end
  context 'with existing id' do
    it 'return the video data and :ok status' do
      get "/videos/#{@video.id}"
      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json['title']).to eq('O vento levou')
    end
  end

  context 'with non existing id' do
    id = 0
    it 'returns 404 record not found' do
      get "/videos/#{id}"
      expect(response).to have_http_status(:not_found)
      expect(response.body).to eq( "{\"error\":\"Couldn't find Video with 'id'=0\"}")
    end
  end
end

