class Post < ApplicationRecord
  def to_param
    slug
  end
end
