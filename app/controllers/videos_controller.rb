class VideosController < ApplicationController
  before_action :set_video, only: [:show, :update, :destroy]

  def index
    if params[:search].present?
      @videos = Video.find_by_title(params[:search])
      if @videos.nil?
        paginate json: {"error": "not found"}
      else
        paginate json: @videos
      end
    else
      @videos = Video.all.page(params[:page])
      paginate json: @videos
    end

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

  def update
    if @video.update(video_params)
      render json: @video
    else
      render json: @video.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @video.destroy
  end

  private

  def video_params
    params.require(:video).permit(:title, :description, :url, :category_id)
  end

  def set_video
    @video = Video.find(params[:id])
  end
end