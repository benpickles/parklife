class PostsController < ApplicationController
  def index
    @posts = Post.order(id: :desc)
  end

  def show
    @post = Post.find_by!(slug: params[:id])
  end
end
