# Parklife

[![GitHub Actions status](https://github.com/benpickles/parklife/workflows/Tests/badge.svg)](https://github.com/benpickles/parklife)

[Parklife](https://github.com/benpickles/parklife) is a Ruby library to render a Rack app (Rails/Sinatra/etc) to a static site so it can be served by [Netlify](https://www.netlify.com), [Now](https://zeit.co/now), [GitHub Pages](https://pages.github.com), S3, or another static server.

## Getting started

Add Parklife to your application's Gemfile and run bundle install.

```ruby
gem 'parklife'
```

Now generate a Parkfile configuration file and build script. Include some Rails- or Sinatra-specific settings by passing `--rails` or `--sinatra`, create a GitHub Actions workflow to generate your Parklife build and push it to GitHub Pages by passing `--github-pages`.

```
$ bundle exec parklife init
```

## How to use Parklife with Rails

Parklife is configured with a file called `Parkfile` in the root of your project, here's an example `Parkfile` for an imaginary Rails app:

```ruby
# Load Parklife's Rails-specific integration which, among other things, allows
# you to use URL helpers within the `routes` block below.
require 'parklife/rails'

# Load the Rails application, this gives you full access to the application's
# environment from this file - using models for example.
require_relative 'config/environment'

Parkfile.application.routes do
  # Start from the homepage and crawl all links.
  root crawl: true

  # Some extra paths that aren't discovered while crawling.
  get feed_path(format: :atom)
  get sitemap_path(format: :xml)

  # A couple more hidden pages.
  get easter_egg_path, crawl: true

  # Services typically allow a custom 404 page.
  get '404.html'
end
```

Listing the routes included in the above Parklife application with `parklife routes` would output the following:

```
$ bundle exec parklife routes
/             crawl=true
/feed.atom
/sitemap.xml
/easter_egg   crawl=true
/404.html
```

Now you can run `parklife build` which will fetch all the routes and save them to the `build` directory ready to be served as a static site. Inspecting the build directory might look like this:

```
$ find build -type f
build/404.html
build/about/index.html
build/blog/index.html
build/blog/2019/03/07/developers-developers-developers/index.html
build/blog/2019/04/21/modern-life-is-rubbish/index.html
build/blog/2019/05/15/introducing-parklife/index.html
build/easter_egg/index.html
build/easter_egg/surprise/index.html
build/index.html
build/location/index.html
build/feed.atom
build/sitemap.xml
```

Parklife doesn't know about assets (images, CSS, etc) so you likely also need to generate those and copy them to the build directory, see the [Rails example's full build script](examples/rails/bin/static-build) for how you might do this.

## More examples

Take a look at the [Rails](examples/rails/Parkfile), [Rack](examples/rack/Parkfile) and [Sinatra](examples/sinatra/Parkfile) working examples within this repository.

## Configuration

### Linking to full URLs

Sometimes you need to point to a link's full URL - maybe for a feed or a social tag URL. You can tell Parklife to make its mock requests with a particular protocol / host by setting its `base` so Rails `*_url` helpers will point to the correct host:

```ruby
Parklife.application.config.base = 'https://foo.example.com'
```

The base URL can also be passed at build-time which will override the Parkfile setting:

```
$ bundle exec parklife build --base https://benpickles.github.io/parklife
```

### Dealing with trailing slashes <small>(turning off nested `index.html`)</small>

By default Parklife stores files in an `index.html` file nested in directory with the same name as the path - so the route `/my/nested/route` is stored in `/my/nested/route/index.html`. This is to make sure links within the app work without modification making it easier for any static server to host the build.

However, it's possible to turn this off so that `/my/nested/route` is stored in `/my/nested/route.html`. This allows you to serve trailing slash-less URLs with GitHub Pages or with Netlify by using their [Pretty URLs feature](https://www.netlify.com/docs/redirects/#trailing-slash) or with some custom nginx config.

```ruby
Parklife.application.config.nested_index = false
```

### Changing the build output directory

The build directory shouldn't exist and is destroyed and recreated before each build. Defaults to `build`.

```ruby
Parklife.application.config.build_dir = 'my/build/dir'
```

### Handling a 404

By default if Parklife encounters a 404 response when fetching a route it will raise an exception (the `:error` setting) and stop the build. Other values are:

- `:warn` - output a message to `stderr`, save the response, and continue processing.
- `:skip` - silently ignore and not save the response, and continue processing.

```ruby
Parklife.application.config.on_404 = :warn
```

### Setting the Rack app

If you're not using the Rails configuration you'll need to define this yourself, see the [examples](examples).

```ruby
Parklife.application.config.app
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Parklife project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/benpickles/parklife/blob/master/CODE_OF_CONDUCT.md).
