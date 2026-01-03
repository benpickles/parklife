# frozen_string_literal: true
RSpec.describe Parklife::Responder::NotFound do
  subject { described_class.new(crawler) }

  let(:config) { Parklife::Config.new }
  let(:crawler) { instance_double('Parklife::Crawler', config: config) }
  let(:response) { Rack::MockResponse.new(404, {}, '') }
  let(:route) { Parklife::Route.new('/404', crawl: false) }

  around do |example|
    old_stderr, $stderr = $stderr, StringIO.new
    example.run
    $stderr = old_stderr
  end

  context 'when on_404=:error' do
    before { config.on_404 = :error }

    it do
      expect {
        subject.call(route, response)
      }.to raise_error(Parklife::HTTPError, '404 response from path "/404"')
    end
  end

  context 'with config.on_404=:skip' do
    before { config.on_404 = :skip }

    it 'does not output anything to stderr' do
      subject.call(route, response)
      expect($stderr.string).to be_empty
    end
  end

  context 'with on_404=:warn' do
    before { config.on_404 = :warn }

    it 'prints a warning to stderr' do
      subject.call(route, response)
      expect($stderr.string.chomp).to eql('404 response from path "/404"')
    end
  end
end
