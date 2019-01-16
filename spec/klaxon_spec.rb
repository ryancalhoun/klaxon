require 'rspec'
require 'securerandom'
require 'klaxon'

describe Klaxon do
  let(:params) { { type: type } }

  shared_context 'continue' do
    context 'with a block' do
      it 'executes the block' do
        expect {|b| subject.alert params, &b }.to yield_control
      end
    end
    context 'without a block' do
      it 'returns true' do
        expect(subject.alert params).to be true
      end
    end
  end
  shared_context 'halt' do
    context 'with a block' do
      before do
        expect(STDERR).to receive(:puts).with(/Skipping/)
      end
      it 'does not execute the block' do
        expect {|b| subject.alert params, &b }.to_not yield_control
      end
    end
    context 'without a block' do
      before do
        expect(STDERR).to receive(:puts).with(/Exiting/)
      end
      it 'exits' do
        expect { subject.alert params }.to raise_error SystemExit
      end
    end
  end

  describe 'enter' do
    before do
      expect(STDERR).to receive(:print).with(/ENTER/)
    end
    let(:type) { Klaxon::ENTER }

    it_behaves_like 'continue' do
      before do
        expect(STDIN).to receive(:gets) { "\n" }
      end
    end
    it_behaves_like 'halt' do
      before do
        expect(STDIN).to receive(:gets).and_raise(Interrupt)
      end
    end
  end

  describe 'yesno' do
    before do
      expect(STDERR).to receive(:print).with(/y\/N/)
    end
    let(:type) { Klaxon::YESNO }

    it_behaves_like 'continue' do
      before do
        expect(STDIN).to receive(:gets) { "y\n" }
      end
    end
    it_behaves_like 'continue' do
      before do
        expect(STDIN).to receive(:gets) { "yes\n" }
      end
    end
    it_behaves_like 'halt' do
      before do
        expect(STDIN).to receive(:gets) { "anything else\n" }
      end
    end
  end

  describe 'random' do
    let(:value) { 'r2d2' }
    before do
      expect(SecureRandom).to receive(:hex).with(2) { value }
      expect(STDERR).to receive(:print).with(/R 2 D 2/)
    end
    let(:type) { Klaxon::RANDOM }

    it_behaves_like 'continue' do
      before do
        expect(STDIN).to receive(:gets) { "#{value}\n" }
      end
    end
    it_behaves_like 'halt' do
      before do
        expect(STDIN).to receive(:gets) { "anything else\n" }
      end
    end
  end

  describe 'a phrase' do
    let(:value) { 'on top of old smokey' }
    before do
      expect(STDERR).to receive(:print).with(/#{value}/)
    end
    let(:type) { value }

    it_behaves_like 'continue' do
      before do
        expect(STDIN).to receive(:gets) { "#{value}\n" }
      end
    end
    it_behaves_like 'halt' do
      before do
        expect(STDIN).to receive(:gets) { "anything else\n" }
      end
    end
  end

  describe 'ci' do
    context 'explicit' do
      it_behaves_like 'continue' do
        let(:params) { { ci: true } }
      end
    end

    context 'implicit' do
      let(:type) { nil }
      before do
        allow(STDIN).to receive(:isatty) { false }
        allow(ENV).to receive(:[])
      end

      it_behaves_like 'continue' do
        before do
          expect(ENV).to receive(:[]).with('CI') { 'true' }
        end
      end
      it_behaves_like 'continue' do
        before do
          expect(ENV).to receive(:[]).with('JENKINS_URL') { 'http://example.com' }
        end
      end
    end

    context 'denied' do
      let(:params) { { ci: false } }
      before do
        allow(STDIN).to receive(:isatty) { false }
        allow(ENV).to receive(:[])
      end
      it_behaves_like 'halt' do
        before do
          expect(ENV).to receive(:[]).with('CI') { 'true' }
        end
      end
    end

  end
end
