## Version 0.3.0 - 2023-02-26

- Allow overriding `config.base` from the CLI build command with the `--base` option.
- Support mounting the app at a path.
- Remove Capybara and use Rack::Test directly.
- Rename `config.rack_app` to `config.app`.
- Don't save the response when `on_404=:skip`.
- More accurate progress dots.
- Default `build_dir` to `build`.
- Fix build paths when `build_dir` isn't a full path.
- Ignore pathless links - for instance #fragments and mailto.

## Version 0.2.0 - 2023-02-21

- First official version hosted on [RubyGems.org](https://rubygems.org/gems/parklife).
- Provide alternatives to blowing up if a 404 is encountered.
- Add the ability to crawl a route by adding `crawl: true` to it.

## Version 0.1.0 - 2019-04-26

The day I started using Parklife in production for [my website](https://www.benpickles.com).
