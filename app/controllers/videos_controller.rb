class VideosController < ApplicationController
  before_action :set_video, only: [:show]
  def index
    @videos = Video.all

    render json: @videos
  end

  def create
    @video = Video.new(video_params)
    if @video.save
      render json: @video, status: :created
    else
      render json: @video.errors, status: :unprocessable_entity
    end
  end

  def show
    render json: @video
  end



  private

  def video_params
    params.require(:video).permit(:title, :description, :url)
  end

  def set_video
    @video = Video.find(params[:id])
  end
end