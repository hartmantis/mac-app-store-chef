require_relative '../../../spec_helper'
require_relative '../../../../libraries/helpers_app'

describe 'resource_mac_app_store_app::mac_os_x::10_10' do
  %i(name app_name system_user action).each do |p|
    let(p) { nil }
  end
  %i(installed? upgradable? app_id_for?).each { |i| let(i) { nil } }
  let(:getlogin) { 'vagrant' }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'mac_app_store_app', platform: 'mac_os_x', version: '10.10'
    ) do |node|
      %i(name app_name system_user action).each do |p|
        unless send(p).nil?
          node.set['resource_mac_app_store_app_test'][p] = send(p)
        end
      end
    end
  end
  let(:converge) { runner.converge('resource_mac_app_store_app_test') }

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

  context 'the default action (:install)' do
    let(:action) { nil }
    let(:name) { 'Some App' }
    let(:app_id_for?) { 'abc123' }

    context 'app not already installed' do
      let(:installed?) { false }
      let(:app_id_for?) { 'abc123' }

      context 'no extra properties' do
        cached(:chef_run) { converge }

        it 'installs the app' do
          expect(chef_run).to run_execute("Install #{name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: getlogin)
        end
      end

      context 'an overridden app_name property' do
        let(:app_name) { 'Other App' }
        cached(:chef_run) { converge }

        it 'installs the app with the correct name' do
          expect(chef_run).to run_execute("Install #{app_name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: getlogin)
        end
      end

      context 'an overridden system_user property' do
        let(:system_user) { 'testme' }
        cached(:chef_run) { converge }

        it 'installs the app with the correct system user' do
          expect(chef_run).to run_execute("Install #{name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: system_user)
        end
      end

      context 'app non-existent' do
        let(:app_id_for?) { nil }
        cached(:chef_run) { converge }

        it 'raises an error' do
          expected = Chef::Resource::MacAppStoreApp::Exceptions::InvalidAppName
          expect { chef_run }.to raise_error(expected)
        end
      end
    end

    context 'app already installed' do
      let(:installed?) { true }
      cached(:chef_run) { converge }

      it 'does not install the app' do
        expect(chef_run).to_not run_execute("Install #{name} with Mas")
      end
    end
  end

  context 'the :upgrade action' do
    let(:action) { :upgrade }
    let(:name) { 'Some App' }
    let(:app_id_for?) { 'abc123' }

    context 'app not already installed' do
      let(:installed?) { false }
      let(:upgradable?) { nil }

      context 'no extra properties' do
        cached(:chef_run) { converge }

        it 'installs the app' do
          expect(chef_run).to run_execute("Upgrade #{name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: getlogin)
        end
      end

      context 'an overridden app_name property' do
        let(:app_name) { 'Other App' }
        cached(:chef_run) { converge }

        it 'upgrades the app with the correct name' do
          expect(chef_run).to run_execute("Upgrade #{app_name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: getlogin)
        end
      end

      context 'an overridden system_user property' do
        let(:system_user) { 'testme' }
        cached(:chef_run) { converge }

        it 'upgrades the app with the correct system user' do
          expect(chef_run).to run_execute("Upgrade #{name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: system_user)
        end
      end

      context 'app non-existent' do
        let(:app_id_for?) { nil }
        cached(:chef_run) { converge }

        it 'raises an error' do
          expected = Chef::Resource::MacAppStoreApp::Exceptions::InvalidAppName
          expect { chef_run }.to raise_error(expected)
        end
      end
    end

    context 'app installed' do
      let(:installed?) { true }

      context 'app upgradable' do
        let(:upgradable?) { true }

        context 'no extra properties' do
          cached(:chef_run) { converge }

          it 'upgrades the app' do
            expect(chef_run).to run_execute("Upgrade #{name} with Mas")
              .with(command: "mas install #{app_id_for?}", user: getlogin)
          end
        end

        context 'an overridden app_name property' do
          let(:app_name) { 'Other App' }
          cached(:chef_run) { converge }

          it 'upgrades the app with the correct name' do
            expect(chef_run).to run_execute("Upgrade #{app_name} with Mas")
              .with(command: "mas install #{app_id_for?}", user: getlogin)
          end
        end

        context 'an overridden system_user property' do
          let(:system_user) { 'testme' }
          cached(:chef_run) { converge }

          it 'upgrades the app with the correct system user' do
            expect(chef_run).to run_execute("Upgrade #{name} with Mas")
              .with(command: "mas install #{app_id_for?}", user: system_user)
          end
        end
      end

      context 'app not upgradable' do
        let(:upgradable?) { false }
        cached(:chef_run) { converge }

        it 'does not upgrade the app' do
          expect(chef_run).to_not run_execute("Upgrade #{name} with Mas")
        end
      end
    end
  end
end
