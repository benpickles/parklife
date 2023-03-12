## Version 0.5.0 - 2023-03-12

- RuboCop. <https://github.com/benpickles/parklife/pull/87>
- Allow passing a --base to all `parklife` commands. <https://github.com/benpickles/parklife/pull/85>
- Configure Rails default_url_options and relative_url_root when setting Parklife base. <https://github.com/benpickles/parklife/pull/85>
- Add `parklife get PATH` command to fetch and output a path. <https://github.com/benpickles/parklife/pull/83>
- Add a `parklife init` command to create a starter Parkfile and friends. <https://github.com/benpickles/parklife/pull/82>
- Fix the HOST header for a non-standard port. <https://github.com/benpickles/parklife/pull/81>

## Version 0.4.0 - 2023-03-01

- Add a `parklife --version` command. <https://github.com/benpickles/parklife/pull/80>
- No need to `require parklife` from the Parkfile. <https://github.com/benpickles/parklife/pull/79>

## Version 0.3.0 - 2023-02-26

- Allow overriding `config.base` from the CLI build command with the `--base` option. <https://github.com/benpickles/parklife/pull/78>
- Support mounting the app at a path. <https://github.com/benpickles/parklife/pull/78>
- Remove Capybara and use Rack::Test directly. <https://github.com/benpickles/parklife/pull/78>
- Rename `config.rack_app` to `config.app`. <https://github.com/benpickles/parklife/pull/78>
- Don't save the response when `on_404=:skip`. <https://github.com/benpickles/parklife/pull/77>
- More accurate progress dots. <https://github.com/benpickles/parklife/pull/75>
- Default `build_dir` to `build`. <https://github.com/benpickles/parklife/pull/73>
- Fix build paths when `build_dir` isn't a full path. <https://github.com/benpickles/parklife/pull/73>
- Ignore pathless links - for instance #fragments and mailto. <https://github.com/benpickles/parklife/pull/72>

## Version 0.2.0 - 2023-02-21

- First official version hosted on [RubyGems.org](https://rubygems.org/gems/parklife).
- Provide alternatives to blowing up if a 404 is encountered. <https://github.com/benpickles/parklife/pull/70>
- Add the ability to crawl a route by adding `crawl: true` to it. <https://github.com/benpickles/parklife/pull/65>

## Version 0.1.0 - 2019-04-26

The day I started using Parklife in production for [my website](https://www.benpickles.com).
