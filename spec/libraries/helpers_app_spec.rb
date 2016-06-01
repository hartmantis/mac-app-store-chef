# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/helpers_app'

describe MacAppStore::Helpers::App do
  let(:user) { 'testme' }

  before(:each) do
    described_class.user = user
  end

  describe '.upgradable?' do
    let(:name) { 'Xcode for OS X' }
    let(:id) { '123456789' }
    let(:upgradable) { nil }
    let(:stdout) do
      lines = [
        '688199928 Docs for Xcode (1.2.3)',
        '926036361 LastPass (3.4.5)',
        '557168941 Tweetbot (4.5.6)',
        '448925439 Marked (5.6.7)',
        '403012667 Textual (6.7.8)'
      ]
      lines.insert(2, "#{id} #{name.tr(' ', '')} (7.8.9)") if upgradable
      lines.join("\n")
    end
    let(:mas_outdated) { double(stdout: stdout) }
    let(:res) { described_class.upgradable?(name) }

    before(:each) do
      allow(described_class).to receive(:shell_out)
        .with('mas outdated', user: user).and_return(mas_outdated)
      allow(described_class).to receive(:app_id_for?).with(name).and_return(id)
    end

    context 'not upgradable' do
      let(:upgradable) { false }

      it 'returns false' do
        expect(res).to eq(false)
      end
    end

    context 'upgradable' do
      let(:upgradable) { true }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end
  end

  describe '.installed?' do
    let(:name) { 'Xcode for OS X' }
    let(:id) { '123456789' }
    let(:installed) { nil }
    let(:stdout) do
      lines = [
        '688199928 Docs for Xcode',
        '926036361 LastPass',
        '557168941 Tweetbot',
        '448925439 Marked',
        '403012667 Textual'
      ]
      lines.insert(2, "#{id} #{name.tr(' ', '')}") if installed
      lines.join("\n")
    end
    let(:mas_list) { double(stdout: stdout) }
    let(:res) { described_class.installed?(name) }

    before(:each) do
      allow(described_class).to receive(:shell_out)
        .with('mas list', user: user).and_return(mas_list)
      allow(described_class).to receive(:app_id_for?).with(name).and_return(id)
    end

    context 'not installed' do
      let(:installed) { false }

      it 'returns false' do
        expect(res).to eq(false)
      end
    end

    context 'installed' do
      let(:installed) { true }

      it 'returns true' do
        expect(res).to eq(true)
      end
    end
  end

  describe '.app_id_for?' do
    let(:name) { nil }
    let(:stdout) { nil }
    let(:mas_search) { double(stdout: stdout) }
    let(:res) { described_class.app_id_for?(name) }

    before(:each) do
      allow(described_class).to receive(:shell_out)
        .with("mas search '#{name}'", user: user).and_return(mas_search)
    end

    context 'no search results' do
      let(:name) { 'Xcodeeee' }
      let(:stdout) { "No results found\n" }

      it 'returns nil' do
        expect(res).to eq(nil)
      end
    end

    context 'a single search result' do
      let(:name) { 'Spice for Xcode' }
      let(:stdout) { "506293178 Spice for Xcode\n" }

      it 'returns the app ID' do
        expect(res).to eq('506293178')
      end
    end

    context 'many search results' do
      let(:name) { 'Xcode' }
      let(:stdout) do
        <<-EOH.gsub(/^ +/, '')
          688199928 Docs for Xcode
          497799835 Xcode
          1083165894 Course for Xcode 7 Lite
          989646576 App Icon Gear - image assets helper for Xcode
          665134234 Training for Xcode
        EOH
      end

      it 'returns the app ID' do
        expect(res).to eq('497799835')
      end
    end
  end
end
