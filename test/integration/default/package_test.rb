# frozen_string_literal: true

control 'mac-app-store::default::package' do
  title 'Tests of the macOS App Store apps'
  impact 1.0

  describe package('com.microsoft.rdc.mac') do
    it { should be_installed }
  end

  describe directory('/Applications/Microsoft Remote Desktop.app') do
    it { should exist }
  end

  describe package('com.tmsoft.mac.WhiteNoiseLite') do
    it { should be_installed }
  end

  describe directory('/Applications/WhiteNoiseFree.app') do
    it { should exist }
  end

  describe command('pgrep "App Store"') do
    its(:exit_status) { should eq(1) }
  end
end
