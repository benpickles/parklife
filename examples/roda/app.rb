require 'roda'

class App < Roda
  plugin :render

  route do |r|
    r.root do
      view 'home'
    end

    r.on 'posts' do
      r.is String do |id|
        r.get do
          @id = id
          view 'show'
        end
      end
    end
  end
end
