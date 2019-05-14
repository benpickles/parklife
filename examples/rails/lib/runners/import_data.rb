Rails.root.join('data').children.each do |path|
  id, slug = path.basename('.*').to_s.split('-', 2)
  title, rest = path.read.split("\n", 2)

  post = Post.find_or_initialize_by(id: id)
  post.body = rest
  post.slug = slug
  post.title = title
  post.save!
end
