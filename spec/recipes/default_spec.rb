# encoding: utf-8
# frozen_string_literal: true

require 'spec_helper'

describe 'mac-app-store::default' do
  %i(username password apps source version system_user use_rtun).each do |a|
    let(a) { nil }
  end
  let(:platform) { { platform: nil, version: nil } }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      %i(username password apps).each do |a|
        node.normal['mac_app_store'][a] = send(a) unless send(a).nil?
      end
      %i(source version system_user use_rtun).each do |a|
        node.normal['mac_app_store']['mas'][a] = send(a) unless send(a).nil?
      end
    end
  end
  let(:converge) { runner.converge(described_recipe) }

  context 'Mac OS X 10.10' do
    let(:platform) { { platform: 'mac_os_x', version: '10.10' } }

    shared_examples_for 'any attribute set' do
      it 'installs Mas' do
        if use_rtun
          expect(chef_run).to install_mac_app_store_mas('default')
            .with(use_rtun: true)
        else
          expect(chef_run).to install_mac_app_store_mas('default')
        end
      end

      it 'signs into Mas' do
        if use_rtun
          expect(chef_run).to sign_in_mac_app_store_mas('default')
            .with(username: username, password: password, use_rtun: true)
        else
          expect(chef_run).to sign_in_mac_app_store_mas('default')
            .with(username: username, password: password)
        end
      end

      it 'installs the specified apps' do
        if apps
          apps.each do |k, v|
            next unless v == true
            if system_user
              expect(chef_run).to install_mac_app_store_app(k)
                .with(system_user: system_user)
            elsif use_rtun
              expect(chef_run).to install_mac_app_store_app(k)
                .with(use_rtun: true)
            else
              expect(chef_run).to install_mac_app_store_app(k)
            end
          end
        else
          expect(chef_run.find_resources(:mac_app_store_app)).to be_empty
        end
      end
    end

    context 'all default attributes' do
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'
    end

    context 'overridden username and password attributes' do
      let(:username) { 'example@example.com' }
      let(:password) { 'abc123' }
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'
    end

    context 'an overridden apps attribute' do
      let(:apps) { { 'App 1' => true, 'App 2' => true, 'App 3' => false } }
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'
    end

    context 'an overridden source attribute' do
      let(:source) { 'homebrew' }
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'

      it 'installs Mas from the desired source' do
        expect(chef_run).to install_mac_app_store_mas('default')
          .with(source: :homebrew)
      end
    end

    context 'an overridden version attribute' do
      let(:version) { '1.2.3' }
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'

      it 'installs the desired version of Mas' do
        expect(chef_run).to install_mac_app_store_mas('default')
          .with(version: '1.2.3')
      end
    end

    context 'an overridden system_user attribute' do
      let(:system_user) { 'myself' }
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'
    end

    context 'overridden apps and system_user attributes' do
      let(:apps) { { 'App 1' => true, 'App 2' => true, 'App 3' => false } }
      let(:system_user) { 'myself' }
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'
    end

    context 'an overridden use_rtun attribute' do
      let(:apps) { { 'App 1' => true, 'App 2' => true, 'App 3' => false } }
      let(:use_rtun) { true }
      cached(:chef_run) { converge }

      it_behaves_like 'any attribute set'
    end
  end

  context 'Ubuntu 14.04' do
    let(:platform) { { platform: 'ubuntu', version: '14.04' } }
    cached(:chef_run) { converge }

    it 'raises an error' do
      expect { chef_run }.to raise_error(Chef::Exceptions::UnsupportedPlatform)
    end
  end
end
