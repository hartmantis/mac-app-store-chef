# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe 'mac-app-store::two-sample-apps::package' do
  describe 'Microsoft Remote Desktop app' do
    describe package('com.microsoft.rdc.mac') do
      it 'is installed' do
        expect(subject).to be_installed.by(:pkgutil)
      end
    end

    describe file('/Applications/Microsoft Remote Desktop.app') do
      it 'is present on the filesystem' do
        expect(subject).to be_directory
      end
    end
  end

  describe 'White Noise Lite app' do
    describe package('com.tmsoft.mac.WhiteNoiseLite') do
      it 'is installed' do
        expect(subject).to be_installed.by(:pkgutil)
      end
    end

    describe file('/Applications/WhiteNoiseFree.app') do
      it 'is present on the filesystem' do
        expect(subject).to be_directory
      end
    end
  end

  describe 'Mac App Store' do
    describe command('pgrep "App Store"') do
      it 'exits 1 (App Store not running)' do
        expect(subject.exit_status).to eq(1)
      end
    end
  end
end
