# encoding: utf-8
# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../libraries/helpers_mas'

describe MacAppStore::Helpers::Mas do
  describe '.upgradable_apps?' do
    let(:stdout) { nil }
    let(:mas_outdated) { double(stdout: "#{stdout}\n") }

    before(:each) do
      allow(described_class).to receive(:shell_out)
        .with('mas outdated').and_return(mas_outdated)
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
  end

  describe '.signed_in_as?' do
    let(:user) { nil }
    let(:mas_account) { double(stdout: user ? "#{user}\n" : "Not signed in\n") }

    before(:each) do
      allow(described_class).to receive(:shell_out)
        .with('mas account').and_return(mas_account)
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
  end
end
