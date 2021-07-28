require 'rails_helper'

RSpec.describe Category, type: :model do
  before do
    @category = Category.new(title: 'LIVRE', color: 'BLUE')
  end

  it 'is valid with valid attributes' do
    expect(@category).to be_valid
  end

  it 'is not valid without a title' do
    @category.title = ''
    expect(@category).to_not be_valid
  end

  it 'is not valid without a color' do
    @category.color = ''
    expect(@category).to_not be_valid
  end
end
