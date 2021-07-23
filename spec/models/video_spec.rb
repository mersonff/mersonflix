require 'rails_helper'

RSpec.describe Video, type: :model do
  before do
    @video = Video.new(title: 'RED', description: 'Lorem Ipsum', url:'http://www.test.com/video')
  end

  it 'is valid with valid attributes' do
    expect(@video).to be_valid
  end

  it 'is not valid without a title' do
    @video.title = ''
    expect(@video).to_not be_valid
  end

  it 'is not valid without a description' do
    @video.description = ''
    expect(@video).to_not be_valid
  end

  it 'is not valid without a url' do
    @video.url = ''
    expect(@video).to_not be_valid
  end

  it 'is not valid with a invalid url' do
    @video.url = 'aaaa.co'
    expect(@video).to_not be_valid
  end
end
