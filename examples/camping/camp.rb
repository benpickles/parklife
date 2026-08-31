require 'camping'

Camping.goes :App

module App::Controllers
  class Index
    def get
      render :index
    end
  end

  class PostsX
    def get(id)
      @id = id
      render :show
    end
  end
end

module App::Views
  def layout
    html do
      head { title 'Parklife Camping example' }
      body do
        self << yield
      end
    end
  end

  def index
    ul do
      %w(foo bar baz).each do |id|
        li do
          a(href: "/posts/#{id}") { id }
        end
      end
    end
  end

  def show
    h1 { @id }
  end
end
