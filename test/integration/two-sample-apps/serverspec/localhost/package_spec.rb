# Encoding: UTF-8

require 'spec_helper'

describe 'Microsoft Remote Desktop app' do
  it 'is present in pkgutil' do
    p = 'com.microsoft.rdc.mac'
    expect(package(p)).to be_installed_by(:pkgutil)
  end

  it 'is present on the filesystem' do
    d = '/Applications/Microsoft Remote Desktop.app'
    expect(file(d)).to be_directory
  end
end

describe 'White Noise Lite app' do
  it 'is present in pkgutil' do
    p = 'com.tmsoft.mac.WhiteNoiseLite'
    expect(package(p)).to be_installed_by(:pkgutil)
  end

  it 'is present on the filesystem' do
    d = '/Applications/WhiteNoiseLite.app'
    expect(file(d)).to be_directory
  end
end
