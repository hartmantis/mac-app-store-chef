require_relative '../../../spec_helper'

describe 'resource_mac_app_store_mas::mac_os_x::10_10' do
  let(:name) { 'default' }
  %i(install_method version username password action).each do |p|
    let(p) { nil }
  end
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: 'mac_app_store_mas', platform: 'mac_os_x', version: '10.10'
    ) do |node|
      %i(name install_method version username password action).each do |p|
        unless send(p).nil?
          node.set['resource_mac_app_store_mas_test'][p] = send(p)
        end
      end
    end
  end
  let(:converge) { runner.converge('resource_mac_app_store_mas_test') }

  before(:each) do
    stub_command('which git').and_return('/usr/bin/git')
    allow(Net::HTTP).to receive(:get).with(
      URI('https://api.github.com/repos/argon/mas/releases')
    ).and_return('[{"tag_name": "v1.3.0"}, {"tag_name": "v1.2.0"}]')
  end

  context 'the default action (:install)' do
    let(:action) { nil }

    context 'the default install method (:direct)' do
      let(:install_method) { nil }
      cached(:chef_run) { converge }

      it 'downloads mas-cli.zip from GitHub' do
        expect(chef_run).to create_remote_file(
          "#{Chef::Config[:file_cache_path]}/mas-cli.zip"
        ).with(source: 'https://github.com/argon/mas/releases/download/' \
                       'v1.3.0/mas-cli.zip')
      end

      it 'unzips mas-cli.zip into place' do
        expect(chef_run).to run_execute('Extract Mas-CLI zip file').with(
          command: 'unzip -d /usr/local/bin/ -o ' \
                   "#{Chef::Config[:file_cache_path]}/mas-cli.zip"
        )
      end
    end

    context 'the :homebrew install method' do
      let(:install_method) { :homebrew }
      cached(:chef_run) { converge }

      it 'includes the homebrew default recipe' do
        expect(chef_run).to include_recipe('homebrew')
      end

      it 'installs Mas via Homebrew' do
        expect(chef_run).to install_homebrew_package('argon/mas/mas')
      end
    end
  end

  context 'the :upgrade action' do
    let(:action) { :upgrade }

    context 'the default install method (:direct)' do
      let(:install_method) { nil }
      cached(:chef_run) { converge }

      it 'downloads mas-cli.zip from GitHub' do
        expect(chef_run).to create_remote_file(
          "#{Chef::Config[:file_cache_path]}/mas-cli.zip"
        ).with(source: 'https://github.com/argon/mas/releases/download/' \
                       'v1.3.0/mas-cli.zip')
      end

      it 'unzips mas-cli.zip into place' do
        expect(chef_run).to run_execute('Extract Mas-CLI zip file').with(
          command: 'unzip -d /usr/local/bin/ -o ' \
                   "#{Chef::Config[:file_cache_path]}/mas-cli.zip"
        )
      end
    end

    context 'the :homebrew install method' do
      let(:install_method) { :homebrew }
      cached(:chef_run) { converge }

      it 'includes the homebrew default recipe' do
        expect(chef_run).to include_recipe('homebrew')
      end

      it 'upgrades Mas via Homebrew' do
        expect(chef_run).to upgrade_homebrew_package('argon/mas/mas')
      end
    end
  end

  context 'the :remove action' do
    let(:action) { :remove }

    context 'the default install method (:direct)' do
      let(:install_method) { nil }
      cached(:chef_run) { converge }

      it 'deletes the mas file' do
        expect(chef_run).to delete_file('/usr/local/bin/mas')
      end
    end

    context 'the :homebrew install method' do
      let(:install_method) { :homebrew }
      cached(:chef_run) { converge }

      it 'includes the homebrew default recipe' do
        expect(chef_run).to include_recipe('homebrew')
      end

      it 'removes Mas via Homebrew' do
        expect(chef_run).to remove_homebrew_package('argon/mas/mas')
      end
    end
  end

  context 'the :sign_in action' do
    let(:action) { :sign_in }
    let(:username) { 'example@example.com' }
    let(:password) { 'abc123' }

    it 'signs into Mas' do
      expect(chef_run).to execite("Sign in to Mas as #{username}")
        .with(command: "mas signin #{username} #{password}")
    end
  end

  context 'the :sign_out action' do
    let(:action) { :sign_out }
    cached(:chef_run) { converge }

    it 'signs out of Mas' do
      expect(chef_run).to run_execute('Sign out of Mas')
        .with(command: 'mas signout')
    end
  end
end
