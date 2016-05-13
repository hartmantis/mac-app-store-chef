require_relative '../../../spec_helper'
require_relative '../../../../libraries/resource_mac_app_store_app'

describe 'resource_mac_app_store_app::mac_os_x::10_10' do
  %i(name app_name action).each do |p|
    let(p) { nil }
  end
  let(:installed) { nil }
  let(:searchable) { nil }
  let(:list) do
    lines = [
      '407370605 FaxFresh',
      '503936035 The 7th Guest',
      '435989461 GIFBrewery'
    ]
    lines.insert(2, "#{id} #{app_name || name}") if installed
    double(stdout: lines.join("\n"))
  end
  let(:search) do
    lines = [
      "123456789 Other #{app_name || name} Thing",
      '503936035 The 7th Guest',
      "123456780 wwwdot#{app_name || name}dotbiz"
    ]
    lines.insert(2, "#{id} #{app_name || name}") if searchable
    double(stdout: lines.join("\n"))
  end
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
    allow_any_instance_of(Chef::Resource::MacAppStoreApp).to receive(:shell_out)
      .with('mas list').and_return(list)
    allow_any_instance_of(Chef::Resource::MacAppStoreApp).to receive(:shell_out)
      .with("mas search '#{app_name || name}'").and_return(search)
    allow(Etc).to receive(:getlogin).and_return(user)
  end

  context 'the default action (:install)' do
    let(:action) { nil }

    context 'no extra properties' do
      let(:name) { 'Some App' }
      let(:id) { 'abc123' }

      context 'app not already installed' do
        let(:searchable) { true }
        let(:installed) { false }
        cached(:chef_run) { converge }

        it 'installs the app' do
          expect(chef_run).to run_execute("Install #{name} with Mas")
            .with(command: "mas install #{id}", user: user)
        end
      end

      context 'app already installed' do
        let(:searchable) { true }
        let(:installed) { true }
        cached(:chef_run) { converge }

        it 'does not install the app' do
          expect(chef_run).to_not run_execute("Install #{name} with Mas")
        end
      end

      context 'app not installed and non-existent' do
        let(:searchable) { false }
        let(:installed) { false }
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
      let(:id) { 'abc123' }

      context 'app not already installed' do
        let(:searchable) { true }
        let(:installed) { false }
        cached(:chef_run) { converge }

        it 'installs the app' do
          expect(chef_run).to run_execute("Install #{app_name} with Mas")
            .with(command: "mas install #{id}", user: user)
        end
      end

      context 'app already installed' do
        let(:searchable) { true }
        let(:installed) { true }
        cached(:chef_run) { converge }

        it 'does not install the app' do
          expect(chef_run).to_not run_execute("Install #{app_name} with Mas")
        end
      end

      context 'app not installed and non-existent' do
        let(:searchable) { false }
        let(:installed) { false }
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
      let(:id) { 'abc123' }
      cached(:chef_run) { converge }

      it 'upgrades the app' do
        pending
        expect(chef_run).to run_execute("Upgrade #{name} with Mas")
          .with(command: "mas upgrade #{id}", user: user)
      end
    end

    context 'an overridden app_name property' do
      let(:name) { 'Some App' }
      let(:app_name) { 'Other App' }
      let(:id) { 'abc123' }

      it 'upgrades the app' do
        pending
        expect(chef_run).to run_execute("Upgrade #{app_name} with Mas")
          .with(command: "mas upgrade #{id}")
      end
    end
  end
end
