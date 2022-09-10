# Parklife

[![GitHub Actions status](https://github.com/benpickles/parklife/workflows/Tests/badge.svg)](https://github.com/benpickles/parklife)

[Parklife](https://github.com/benpickles/parklife) is a Ruby library to render a Rack app (Rails/Sinatra/etc) to a static site so it can be served by [Netlify](https://www.netlify.com), [Now](https://zeit.co/now), [GitHub Pages](https://pages.github.com), S3, or another static server.

## How to use Parklife with Rails

Parklife is configured with a file called `Parkfile` in the root of your project, here's an example `Parkfile` for an imaginary Rails app:

```ruby
# Load the Rails application, this gives you full access to the application's
# environment from this file - using models for example.
require_relative 'config/environment'

# Load Parklife and some Rails-specific settings allowing you to use URL
# helpers within the `routes` block below.
require 'parklife/rails'

Parkfile.application.routes do
  # The homepage.
  root

  # A couple of custom pages.
  get about_path
  get location_path

  # All blog posts.
  BlogPost.find_each do |blog_post|
    get blog_post_path(blog_post)
  end

  # Some extras.
  get feed_path(format: :atom)
  get sitemap_path(format: :xml)
end
```

Listing the routes included in the above Parklife application with `parklife routes` would output the following:

```
$ bundle exec parklife routes
/
/about
/location
/blog/2019/03/07/developers-developers-developers
/blog/2019/04/21/modern-life-is-rubbish
/blog/2019/05/15/introducing-parklife
/feed.atom
/sitemap.xml
```

Now you can run `parklife build` which will fetch all the routes and save them to the `build` directory ready to be served as a static site.

Parklife doesn't know about assets (images, CSS, etc) so you likely also need to generate those and copy them to the build directory, see the [Rails example's full build script](examples/rails/parklife-build) for how you might do this.

## More examples

Take a look at the [Rails](examples/rails/Parkfile), [Rack](examples/rack/Parkfile) and [Sinatra](examples/sinatra/Parkfile) working examples within this repository.

## Configuration

### Linking to full URLs

Sometimes you need to point to a link's full URL - maybe for a feed or a social tag URL. You can tell Parklife to make its mock requests with a particular protocol / host by setting its `base` so Rails `*_url` helpers will point to the correct host:

```ruby
Parklife.application.config.base = 'https://foo.example.com'
```

### Dealing with trailing slashes <small>(turning off nested `index.html`)</small>

By default Parklife stores files in an `index.html` file nested in directory with the same name as the path - so the route `/my/nested/route` is stored in `/my/nested/route/index.html`. This is to make sure links within the app work without modification making it easier for any static server to host the build.

However, it's possible to turn this off so that `/my/nested/route` is stored in `/my/nested/route.html`. This allows you to serve trailing slash-less URLs by using [Netlify's Pretty URLs feature](https://www.netlify.com/docs/redirects/#trailing-slash) or with some custom nginx config.

```ruby
Parklife.application.config.nested_index = false
```

### Changing the build output directory

The build directory shouldn't exist and is completely recreated before each build.

```ruby
Parklife.application.config.build_dir = 'my/build/dir'
```

### Setting the Rack app

If you're not using the Rails configuration you'll need to define this yourself, see the [examples](examples).

```ruby
Parklife.application.config.rack_app
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Parklife project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/benpickles/parklife/blob/master/CODE_OF_CONDUCT.md).
