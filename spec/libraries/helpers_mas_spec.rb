# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/helpers_mas'

describe MacAppStore::Helpers::Mas do
  describe '.upgradable_apps?' do
    let(:installed) { nil }
    let(:stdout) { nil }
    let(:mas_outdated) { double(stdout: "#{stdout}\n") }

    before(:each) do
      allow(described_class).to receive(:installed?).and_return(installed)
      allow(described_class).to receive(:shell_out).with('mas outdated')
        .and_return(mas_outdated)
    end

    context 'upgrades available' do
      let(:installed) { true }
      let(:stdout) { "123456789 App 1\n234567890 App 2" }

      it 'returns true' do
        expect(described_class.upgradable_apps?).to eq(true)
      end
    end

    context 'no upgrades available' do
      let(:installed) { true }
      let(:stdout) { nil }

      it 'returns false' do
        expect(described_class.upgradable_apps?).to eq(false)
      end
    end

    context 'Mas not installed' do
      let(:installed) { false }

      it 'returns nil' do
        expect(described_class.upgradable_apps?).to eq(nil)
      end
    end
  end

  describe '.signed_in_as?' do
    let(:installed) { nil }
    let(:user) { nil }
    let(:mas_account) { double(stdout: user ? "#{user}\n" : "Not signed in\n") }

    before(:each) do
      allow(described_class).to receive(:installed?).and_return(installed)
      allow(described_class).to receive(:shell_out).with('mas account')
        .and_return(mas_account)
    end

    context 'signed in' do
      let(:installed) { true }
      let(:user) { 'example@example.com' }

      it 'returns the user' do
        expect(described_class.signed_in_as?).to eq('example@example.com')
      end
    end

    context 'not signed in' do
      let(:installed) { true }
      let(:user) { nil }

      it 'returns nil' do
        expect(described_class.signed_in_as?).to eq(nil)
      end
    end

    context 'not installed' do
      let(:installed) { false }

      it 'returns nil' do
        expect(described_class.signed_in_as?).to eq(nil)
      end
    end
  end

  describe '.installed_by?' do
    let(:installed) { nil }
    let(:installed_by) { nil }
    let(:brew_list) do
      double(stdout: installed_by == :homebrew ? "stuff\n" : "\n")
    end

    before(:each) do
      allow(described_class).to receive(:installed?).and_return(installed)
      allow(described_class).to receive(:shell_out)
        .with('brew list argon/mas/mas || true').and_return(brew_list)
    end

    context 'installed by Homebrew' do
      let(:installed) { true }
      let(:installed_by) { :homebrew }

      it 'returns :homebrew' do
        expect(described_class.installed_by?).to eq(:homebrew)
      end
    end

    context 'installed directly from GitHub' do
      let(:installed) { true }
      let(:installed_by) { :direct }

      it 'returns :direct' do
        expect(described_class.installed_by?).to eq(:direct)
      end
    end

    context 'not installed' do
      let(:installed) { false }

      it 'returns nil' do
        expect(described_class.installed_by?).to eq(nil)
      end
    end
  end

  describe '.installed_version?' do
    let(:installed) { nil }
    let(:version) { nil }
    let(:mas_version) { double(stdout: installed ? "#{version}\n" : "\n") }

    before(:each) do
      allow(described_class).to receive(:installed?).and_return(installed)
      allow(described_class).to receive(:shell_out).with('mas version || true')
        .and_return(mas_version)
    end

    context 'installed' do
      let(:installed) { true }
      let(:version) { '1.2.3' }

      it 'returns the installed version' do
        expect(described_class.installed_version?).to eq('1.2.3')
      end
    end

    context 'not installed' do
      let(:installed) { false }

      it 'returns nil' do
        expect(described_class.installed_version?).to eq(nil)
      end
    end
  end

  describe '.installed?' do
    let(:installed) { nil }
    let(:mas_version) { double(stdout: installed ? "stuff\n" : "\n") }

    before(:each) do
      allow(described_class).to receive(:shell_out).with('mas version || true')
        .and_return(mas_version)
    end

    context 'installed' do
      let(:installed) { true }

      it 'returns true' do
        expect(described_class.installed?).to eq(true)
      end
    end

    context 'not installed' do
      let(:installed) { false }

      it 'returns false' do
        expect(described_class.installed?).to eq(false)
      end
    end
  end

  describe '.latest_version?' do
    let(:version) { '1.2.3' }

    before(:each) do
      allow(Net::HTTP).to receive(:get).with(
        URI('https://api.github.com/repos/argon/mas/releases')
      ).and_return(
        %([{"tag_name": "v#{version}"}, {"tag_name": "v0.1.0"}])
      )
    end

    it 'returns the latest version from GitHub' do
      expect(described_class.latest_version?).to eq('1.2.3')
    end
  end
end
