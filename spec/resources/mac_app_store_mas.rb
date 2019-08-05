# encoding: utf-8
# frozen_string_literal: true

require_relative '../resources'

shared_context 'resources::mac_app_store_mas' do
  include_context 'resources'

  let(:resource) { 'mac_app_store_mas' }
  %w[
    source version username password
  ].each { |p| let(p) { nil } }
  let(:properties) do
    {
      source: source,
      version: version,
      username: username,
      password: password
    }
  end
  let(:name) { 'default' }

  %i[
    installed?
    installed_version?
    installed_by?
    signed_in_as?
    latest_version?
    upgradable_apps?
  ].each do |p|
    let(p) { nil }
  end

  before(:each) do
    allow(Kernel).to receive(:load).and_call_original
    allow(Kernel).to receive(:load)
      .with(%r{mac-app-store/libraries/helpers_mas\.rb}).and_return(true)
    {
      latest_version?: latest_version?,
      installed?: installed?,
      installed_version?: installed_version?,
      installed_by?: installed_by?,
      signed_in_as?: signed_in_as?,
      upgradable_apps?: upgradable_apps?
    }.each do |k, v|
      allow(MacAppStore::Helpers::Mas).to receive(k).and_return(v)
    end
  end

  before(:each) do
    stub_command('which git').and_return('/usr/bin/git')
  end

  shared_context 'the :install action' do
    let(:username) { 'example@example.com' }
    let(:password) { 'abc123' }
    let(:latest_version?) { '1.3.0' }
    let(:action) { :install }
  end

  shared_context 'the :upgrade action' do
    let(:latest_version?) { '1.3.0' }
    let(:action) { :upgrade }
  end

  shared_context 'the :remove action' do
    let(:action) { :remove }
  end

  shared_context 'the :sign_in action' do
    let(:action) { :sign_in }
    let(:username) { 'example@example.com' }
    let(:password) { 'abc123' }
  end

  shared_context 'the :sign_out action' do
    let(:action) { :sign_out }
  end

  shared_context 'the :upgrade_apps action' do
    let(:action) { :upgrade_apps }
  end

  shared_context 'all default properties' do
  end

  shared_context 'an overridden source property' do
    let(:source) { :direct }
  end

  shared_context 'an overridden source and version property' do
    let(:source) { :direct }
    let(:version) { '0.1.0' }
  end

  shared_context 'a missing username property' do
    let(:username) { nil }
  end

  shared_context 'a missing password property' do
    let(:password) { nil }
  end

  shared_context 'not already installed' do
    let(:installed?) { false }
  end

  shared_context 'already installed' do
    let(:installed?) { true }
    let(:installed_version?) { '1.3.0' }
    let(:installed_by?) { :direct }
  end

  shared_context 'installed and upgradable' do
    let(:installed?) { true }
    let(:installed_version?) { '1.2.0' }
    let(:installed_by?) { :direct }
  end

  shared_context 'not already signed in' do
  end

  shared_context 'already signed in' do
    let(:signed_in_as?) { 'example@example.com' }
  end

  shared_context 'signed in as someone else' do
    let(:signed_in_as?) { '2@example.com' }
  end

  shared_context 'no app upgrades available' do
    let(:upgradable_apps?) { false }
  end

  shared_context 'app upgrades available' do
    let(:upgradable_apps?) { true }
  end

  shared_examples_for 'any platform' do
    context 'the :install action' do
      include_context description

      it 'installs a mac_app_store_mas resource' do
        expect(chef_run).to install_mac_app_store_mas(name)
      end
    end

    context 'the :upgrade action' do
      include_context description

      it 'upgrades a mac_app_store_mas resource' do
        expect(chef_run).to upgrade_mac_app_store_mas(name)
      end
    end

    context 'the :remove action' do
      include_context description

      it 'removes a mac_app_store_mas resource' do
        expect(chef_run).to remove_mac_app_store_mas(name)
      end
    end

    context 'the :sign_in action' do
      include_context description

      context 'already installed' do
        include_context description

        it 'signs in a mac_app_store_mas resource' do
          expect(chef_run).to sign_in_mac_app_store_mas(name)
        end
      end
    end

    context 'the :sign_out action' do
      include_context description

      context 'already installed' do
        include_context description

        it 'signs out a mac_app_store_mas resource' do
          expect(chef_run).to sign_out_mac_app_store_mas(name)
        end
      end
    end

    context 'the :upgrade_apps action' do
      include_context description

      context 'already installed' do
        include_context description

        it 'upgrades apps on a mac_app_store_mas resource' do
          expect(chef_run).to upgrade_apps_mac_app_store_mas(name)
        end
      end
    end
  end
end
