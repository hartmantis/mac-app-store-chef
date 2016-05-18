require_relative '../../../spec_helper'
require_relative '../../../../libraries/helpers_app'

describe 'resource_mac_app_store_app::mac_os_x::10_10' do
  %i(name app_name action).each do |p|
    let(p) { nil }
  end
  %i(installed? upgradable? app_id_for?).each { |i| let(i) { nil } }
  let(:user) { 'vagrant' }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'mac_app_store_app', platform: 'mac_os_x', version: '10.10'
    ) do |node|
      %i(name app_name action).each do |p|
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
    allow(Etc).to receive(:getlogin).and_return(user)
  end

  context 'the default action (:install)' do
    let(:action) { nil }

    context 'no extra properties' do
      let(:name) { 'Some App' }

      context 'app not already installed' do
        let(:installed?) { false }
        let(:app_id_for?) { 'abc123' }
        cached(:chef_run) { converge }

        it 'installs the app' do
          expect(chef_run).to run_execute("Install #{name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: user)
        end
      end

      context 'app already installed' do
        let(:installed?) { true }
        let(:app_id_for?) { 'abc123' }
        cached(:chef_run) { converge }

        it 'does not install the app' do
          expect(chef_run).to_not run_execute("Install #{name} with Mas")
        end
      end

      context 'app not installed and non-existent' do
        let(:installed?) { false }
        let(:app_id_for?) { nil }
        cached(:chef_run) { converge }

        it 'raises an error' do
          expected = Chef::Resource::MacAppStoreApp::Exceptions::InvalidAppName
          expect { chef_run }.to raise_error(expected)
        end
      end
    end

    context 'an overridden app_name property' do
      let(:name) { 'Some App' }
      let(:app_name) { 'Other App' }

      context 'app not already installed' do
        let(:installed?) { false }
        let(:app_id_for?) { 'abc123' }
        cached(:chef_run) { converge }

        it 'installs the app' do
          expect(chef_run).to run_execute("Install #{app_name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: user)
        end
      end

      context 'app already installed' do
        let(:installed?) { true }
        let(:app_id_for?) { 'abc123' }
        cached(:chef_run) { converge }

        it 'does not install the app' do
          expect(chef_run).to_not run_execute("Install #{app_name} with Mas")
        end
      end

      context 'app not installed and non-existent' do
        let(:installed?) { false }
        let(:app_id_for?) { nil }
        cached(:chef_run) { converge }

        it 'raises an error' do
          expected = Chef::Resource::MacAppStoreApp::Exceptions::InvalidAppName
          expect { chef_run }.to raise_error(expected)
        end
      end
    end
  end

  context 'the :upgrade action' do
    let(:action) { :upgrade }

    context 'no extra properties' do
      let(:name) { 'Some App' }

      context 'app not already installed' do
        let(:installed?) { false }
        let(:upgradable?) { nil }
        let(:app_id_for?) { 'abc123' }
        cached(:chef_run) { converge }

        it 'installs the app' do
          expect(chef_run).to run_execute("Upgrade #{name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: user)
        end
      end

      context 'app installed and upgradable' do
        let(:installed?) { true }
        let(:upgradable?) { true }
        let(:app_id_for?) { 'abc123' }
        cached(:chef_run) { converge }

        it 'upgrades the app' do
          expect(chef_run).to run_execute("Upgrade #{name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: user)
        end
      end

      context 'app installed and not upgradable' do
        let(:installed?) { true }
        let(:upgradable?) { false }
        let(:app_id_for?) { 'abc123' }
        cached(:chef_run) { converge }

        it 'does not upgrade the app' do
          expect(chef_run).to_not run_execute("Upgrade #{name} with Mas")
        end
      end

      context 'app not installed and non-existent' do
        let(:installed?) { false }
        let(:upgradable?) { nil }
        let(:app_id_for?) { nil }
        cached(:chef_run) { converge }

        it 'raises an error' do
          expected = Chef::Resource::MacAppStoreApp::Exceptions::InvalidAppName
          expect { chef_run }.to raise_error(expected)
        end
      end
    end

    context 'an overridden app_name property' do
      let(:name) { 'Some App' }
      let(:app_name) { 'Other App' }

      context 'app not already installed' do
        let(:installed?) { false }
        let(:upgradable?) { nil }
        let(:app_id_for?) { 'abc123' }
        cached(:chef_run) { converge }

        it 'installs the app' do
          expect(chef_run).to run_execute("Upgrade #{app_name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: user)
        end
      end

      context 'app installed and upgradable' do
        let(:installed?) { true }
        let(:upgradable?) { true }
        let(:app_id_for?) { 'abc123' }
        cached(:chef_run) { converge }

        it 'upgrades the app' do
          expect(chef_run).to run_execute("Upgrade #{app_name} with Mas")
            .with(command: "mas install #{app_id_for?}", user: user)
        end
      end

      context 'app installed and not upgradable' do
        let(:installed?) { true }
        let(:upgradable?) { false }
        let(:app_id_for?) { 'abc123' }
        cached(:chef_run) { converge }

        it 'does not upgrade the app' do
          expect(chef_run).to_not run_execute("Upgrade #{app_name} with Mas")
        end
      end

      context 'app not installed and non-existent' do
        let(:installed?) { false }
        let(:upgradable?) { nil }
        let(:app_id_for?) { nil }
        cached(:chef_run) { converge }

        it 'raises an error' do
          expected = Chef::Resource::MacAppStoreApp::Exceptions::InvalidAppName
          expect { chef_run }.to raise_error(expected)
        end
      end
    end
  end
end
