## Unreleased

## Version 0.8.0.beta1 - 2025-08-10

- Remove out-of-the-box Rails integration in preparation for a separate gem. <https://github.com/benpickles/parklife/pull/131>
- Include the port when automatically assigning the base from Rails `default_url_options`. <https://github.com/benpickles/parklife/pull/130>
- Improve the HTTP redirect error message to include the request's full URL and redirect location. <https://github.com/benpickles/parklife/pull/129>
- Empty the build directory instead of deleting it. <https://github.com/benpickles/parklife/pull/125>
- Resurrect build callbacks (`before_build`/`after_build`). <https://github.com/benpickles/parklife/pull/124>

## Version 0.7.0 - 2025-02-03

- Add support for Rails 8 and add test infrastructure to ensure future compatibility with Rails 7.0, 7.1, and 8.0. <https://github.com/benpickles/parklife/pull/115>, <https://github.com/benpickles/parklife/pull/117>, <https://github.com/benpickles/parklife/pull/121>
- Improve out-of-the-box compatibility with Rails by reading `default_url_options`, `relative_url_root`, and `force_ssl` settings on boot and applying them to Parklife's `config.base` (`force_ssl` has been set to `true` in `production.rb` since Rails 7.1). <https://github.com/benpickles/parklife/pull/118>
- Improve out-of-the-box compatibility with Sinatra 4.1 which has host authorisation middleware enabled by default in development mode and would otherwise respond to Parklife requests with a 403 status. Additionally the generated Sinatra production build script now sets the environment variable `APP_ENV=production` to enable production mode. <https://github.com/benpickles/parklife/pull/123>, <https://github.com/benpickles/parklife/pull/122>
- When discovering HTML links ignore `<a>` elements without an `href`. <https://github.com/benpickles/parklife/pull/107>

## Version 0.6.1 - 2024-08-23

- Don't error when the public directory doesn't exist <https://github.com/benpickles/parklife/pull/105>

## Version 0.6.0 - 2023-03-26

- Allow assigning a URI object to config.base <https://github.com/benpickles/parklife/pull/98>

- Add a `parklife config` command to output the full Parklife config <https://github.com/benpickles/parklife/pull/97>

- Improved Rails integration <https://github.com/benpickles/parklife/pull/96>

  Parklife now integrates with Rails via Railties and can therefore hook into the app's configuration before it's initialised. This allows Parklife to remove the host authorisation middleware that's present in development and otherwise causes Parklife requests to receive a 403 response.

  **Upgrading**: For an existing Parklife+Rails integration move requiring `parklife/rails` above requiring `config/environment` in the Parkfile.

- Prevent `Encoding::UndefinedConversionError` error when writing a binary response <https://github.com/benpickles/parklife/pull/94>

## Version 0.5.1 - 2023-03-22

- Ensure the generated static-build script is executable. <https://github.com/benpickles/parklife/pull/89>

## Version 0.5.0 - 2023-03-12

- RuboCop. <https://github.com/benpickles/parklife/pull/87>
- Allow passing `--base` to all `parklife` commands. <https://github.com/benpickles/parklife/pull/85>
- Configure Rails `default_url_options` and `relative_url_root` when setting Parklife base. <https://github.com/benpickles/parklife/pull/85>
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
