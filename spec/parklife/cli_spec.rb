require 'parklife/cli'

RSpec.describe Parklife::CLI do
  describe 'init' do
    subject { described_class.new.invoke(:init, [], options) }

    let(:tmpdir) { Dir.mktmpdir }

    around do |example|
      Dir.chdir(tmpdir) { example.run }
    end

    after do
      FileUtils.remove_entry_secure(tmpdir)
    end

    context 'with no args' do
      let(:options) { {} }

      it do
        expect { subject }.to output.to_stdout
          .and change { File.exist?('Parkfile') }.to(true)
          .and change { File.exist?('bin/static-build') }.to(true)
      end
    end

    context '--rails' do
      let(:options) { { rails: true } }

      it do
        expect { subject }.to output.to_stdout

        expect(File.read('Parkfile')).to include(
          "require 'parklife/rails'",
          'feed_path(format: :atom)'
        )

        expect(File.read('bin/static-build'))
          .to include('rails assets:precompile')
      end
    end

    context '--sinatra' do
      let(:options) { { sinatra: true } }

      it do
        expect { subject }.to output.to_stdout

        expect(File.read('Parkfile')).to include('Sinatra::Application')
      end
    end

    context '--github-pages' do
      let(:options) { { github_pages: true } }

      it do
        expect { subject }.to output.to_stdout
          .and change { File.exist?('.github/workflows/parklife.yml') }.to(true)

        expect(File.read('Parkfile')).to include('.nested_index = false')
      end
    end
  end
end
