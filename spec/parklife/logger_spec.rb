# frozen_string_literal: true
RSpec.describe Parklife::Logger do
  subject { described_class.new(stdout, stderr, no_colour: no_colour) }

  let(:no_colour) { false }
  let(:stderr) { StringIO.new }
  let(:stdout) { StringIO.new }

  before do
    thor_color = subject.instance_variable_get(:@thor_color)
    allow(thor_color).to receive(:stdout).and_return(stdout)
  end

  describe '#colour' do
    context 'when stdout is a tty' do
      before do
        allow(stdout).to receive(:tty?).and_return(true)
      end

      it 'colourises the string' do
        expect(subject.colour('hello', :red)).to eql("\e[31mhello\e[0m")
      end

      context 'but #no_colour=true' do
        let(:no_colour) { true }

        it 'does not include colours' do
          expect(subject.colour('hello', :red)).to eql('hello')
        end
      end
    end
  end
end
