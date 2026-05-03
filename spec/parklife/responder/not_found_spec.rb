# frozen_string_literal: true
RSpec.describe Parklife::Responder::NotFound do
  subject { described_class.new(crawler) }

  let(:config) { Parklife::Config.new }
  let(:crawler) { instance_double('Parklife::Crawler', config: config) }
  let(:logger) { config.logger }
  let(:response) { Rack::MockResponse.new(404, {}, '') }
  let(:route) { Parklife::Route.new('/404', crawl: false) }

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

    it 'does nothing' do
      expect(logger).not_to receive(:warn)
      subject.call(route, response)
    end
  end

  context 'with on_404=:warn' do
    before { config.on_404 = :warn }

    it 'a warning is sent to the logger' do
      expect(logger).to receive(:warn).with('404 response from path "/404"')
      subject.call(route, response)
    end
  end
end
