require 'rails_helper'

describe 'GET all videos route', type: :request do
  before do
    10.times do
      @video = Video.create(title: "O vento levou", description: "Loren Ipsum", url: "www.teste.com")
    end
  end

  describe 'GET' do
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