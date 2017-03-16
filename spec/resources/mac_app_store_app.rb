# encoding: utf-8
# frozen_string_literal: true

require_relative '../resources'

shared_context 'resources::mac_app_store_app' do
  include_context 'resources'

  let(:resource) { 'mac_app_store_app' }
  %w(app_name system_user use_rtun).each { |p| let(p) { nil } }
  let(:properties) do
    { app_name: app_name, system_user: system_user, use_rtun: use_rtun }
  end
  let(:name) { 'Some App' }

  %i(installed? upgradable?).each { |i| let(i) { nil } }
  let(:app_id_for?) { 'abc123' }
  let(:getlogin) { 'vagrant' }

  before(:each) do
    allow(Kernel).to receive(:load).and_call_original
    allow(Kernel).to receive(:load)
      .with(%r{mac-app-store/libraries/helpers_app\.rb}).and_return(true)
    {
      installed?: installed?,
      upgradable?: upgradable?,
      app_id_for?: app_id_for?
    }.each do |k, v|
      allow(MacAppStore::Helpers::App).to receive(k).and_return(v)
    end
    allow(Etc).to receive(:getlogin).and_return(getlogin)
  end

  shared_context 'the :install action' do
  end

  shared_context 'the :upgrade action' do
    let(:action) { :upgrade }
  end

  shared_context 'all default properties' do
  end

  shared_context 'an overridden app_name property' do
    let(:app_name) { 'Other App' }
  end

  shared_context 'an overridden system_user property' do
    let(:system_user) { 'testme' }
  end

  shared_context 'an overridden use_rtun property' do
    let(:use_rtun) { true }
  end

  shared_context 'app not already installed' do
    let(:installed?) { false }
  end

  shared_context 'app already installed' do
    let(:installed?) { true }
    let(:upgradable?) { false }
  end

  shared_context 'app installed and upgradable' do
    let(:installed?) { true }
    let(:upgradable?) { true }
  end

  shared_context 'app non-existent' do
    let(:app_id_for?) { nil }
  end

  shared_examples_for 'any platform' do
    context 'the :install action' do
      include_context description

      it 'installs a mac_app_store_app resource' do
        expect(chef_run).to install_mac_app_store_app(name)
      end
    end

    context 'the :upgrade action' do
      include_context description

      it 'upgrades a mac_app_store_app resource' do
        expect(chef_run).to upgrade_mac_app_store_app(name)
      end
    end
  end
end
