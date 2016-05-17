require_relative '../../../spec_helper'
require_relative '../../../../libraries/resource_mac_app_store_mas'

describe 'resource_mac_app_store_mas::mac_os_x::10_10' do
  let(:name) { 'default' }
  %i(install_method version username password action).each do |p|
    let(p) { nil }
  end
  %i(
    installed installed_version installed_by signed_in_as latest_version
  ).each do |p|
    let(p) { nil }
  end
  let(:mas_version) do
    double(stdout: installed ? "#{installed_version}\n" : "\n")
  end
  let(:brew_list) do
    double(stdout: installed_by.nil? || installed_by == :direct ? '' : 'hi')
  end
  let(:mas_account) { double(stdout: "#{signed_in_as}\n") }
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
    ).and_return(
      %Q([{"tag_name": "v#{latest_version}"}, {"tag_name": "v0.1.0"}])
    )
    allow_any_instance_of(Chef::Resource::MacAppStoreMas).to receive(:shell_out)
      .with('mas version || true').and_return(mas_version)
    allow_any_instance_of(Chef::Resource::MacAppStoreMas).to receive(:shell_out)
      .with('brew list argon/mas/mas || true').and_return(brew_list)
    allow_any_instance_of(Chef::Resource::MacAppStoreMas).to receive(:shell_out)
      .with('mas account').and_return(mas_account)
  end

  context 'the default action (:install)' do
    let(:action) { nil }
    let(:latest_version) { '1.3.0' }

    context 'the default install method (:direct)' do
      let(:install_method) { nil }

      context 'not already installed' do
        let(:installed) { false }
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

      context 'already installed' do
        let(:installed) { true }
        let(:installed_version) { '1.1.0' }
        cached(:chef_run) { converge }

        it 'does not download mas-cli.zip from GitHub' do
          expect(chef_run).to_not create_remote_file(
            "#{Chef::Config[:file_cache_path]}/mas-cli.zip"
          )
        end

        it 'does not unzip mas-cli.zip into place' do
          expect(chef_run).to_not run_execute('Extract Mas-CLI zip file')
        end
      end
    end

    context 'the :homebrew install method' do
      let(:install_method) { :homebrew }

      context 'not already installed' do
        let(:installed) { false }
        cached(:chef_run) { converge }

        it 'includes the homebrew default recipe' do
          expect(chef_run).to include_recipe('homebrew')
        end

        it 'installs Mas via Homebrew' do
          expect(chef_run).to install_homebrew_package('argon/mas/mas')
        end
      end

      context 'already installed' do
        let(:installed) { true }
        let(:installed_version) { '1.1.0' }
        cached(:chef_run) { converge }

        it 'does not include the homebrew default recipe' do
          expect(chef_run).to_not include_recipe('homebrew')
        end

        it 'does not install Mas via Homebrew' do
          expect(chef_run).to_not install_homebrew_package('argon/mas/mas')
        end
      end
    end
  end

  context 'the :upgrade action' do
    let(:action) { :upgrade }
    let(:latest_version) { '1.5.0' }

    context 'the default install method (:direct)' do
      let(:install_method) { nil }

      context 'not already installed' do
        let(:installed) { false }
        cached(:chef_run) { converge }

        it 'downloads mas-cli.zip from GitHub' do
          expect(chef_run).to create_remote_file(
            "#{Chef::Config[:file_cache_path]}/mas-cli.zip"
          ).with(source: 'https://github.com/argon/mas/releases/download/' \
                         'v1.5.0/mas-cli.zip')
        end

        it 'unzips mas-cli.zip into place' do
          expect(chef_run).to run_execute('Extract Mas-CLI zip file').with(
            command: 'unzip -d /usr/local/bin/ -o ' \
                     "#{Chef::Config[:file_cache_path]}/mas-cli.zip"
          )
        end
      end

      context 'already installed' do
        let(:installed) { true }
        let(:installed_version) { '1.5.0' }
        cached(:chef_run) { converge }

        it 'does not download mas-cli.zip from GitHub' do
          expect(chef_run).to_not create_remote_file(
            "#{Chef::Config[:file_cache_path]}/mas-cli.zip"
          )
        end

        it 'does not unzip mas-cli.zip into place' do
          expect(chef_run).to_not run_execute('Extract Mas-CLI zip file')
        end
      end

      context 'installed but in need of an upgrade' do
        let(:installed) { true }
        let(:installed_version) { '1.4.0' }
        cached(:chef_run) { converge }


        it 'downloads mas-cli.zip from GitHub' do
          expect(chef_run).to create_remote_file(
            "#{Chef::Config[:file_cache_path]}/mas-cli.zip"
          ).with(source: 'https://github.com/argon/mas/releases/download/' \
                         'v1.5.0/mas-cli.zip')
        end

        it 'unzips mas-cli.zip into place' do
          expect(chef_run).to run_execute('Extract Mas-CLI zip file').with(
            command: 'unzip -d /usr/local/bin/ -o ' \
                     "#{Chef::Config[:file_cache_path]}/mas-cli.zip"
          )
        end
      end
    end

    context 'the :homebrew install method' do
      let(:install_method) { :homebrew }

      context 'not already installed' do
        let(:installed) { false }
        cached(:chef_run) { converge }

        it 'includes the homebrew default recipe' do
          expect(chef_run).to include_recipe('homebrew')
        end

        it 'upgrades Mas via Homebrew' do
          expect(chef_run).to upgrade_homebrew_package('argon/mas/mas')
        end
      end

      context 'already installed' do
        let(:installed) { true }
        let(:installed_version) { '1.5.0' }
        cached(:chef_run) { converge }

        it 'does not include the homebrew default recipe' do
          expect(chef_run).to_not include_recipe('homebrew')
        end

        it 'does not upgrade Mas via Homebrew' do
          expect(chef_run).to_not upgrade_homebrew_package('argon/mas/mas')
        end
      end

      context 'installed but in need of an upgrade' do
        let(:installed) { true }
        let(:installed_version) { '1.4.0' }
        cached(:chef_run) { converge }

        it 'includes the homebrew default recipe' do
          expect(chef_run).to include_recipe('homebrew')
        end

        it 'upgrades Mas via Homebrew' do
          expect(chef_run).to upgrade_homebrew_package('argon/mas/mas')
        end
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
    let(:installed) { true }
    let(:username) { 'example@example.com' }
    let(:password) { 'abc123' }

    context 'not signed in' do
      let(:signed_in_as) { nil }
      cached(:chef_run) { converge }

      it 'signs into Mas' do
        expect(chef_run).to run_execute("Sign in to Mas as #{username}")
          .with(command: "mas signin #{username} #{password}")
      end
    end

    context 'already signed in' do
      let(:signed_in_as) { 'example@example.com' }
      cached(:chef_run) { converge }

      it 'does not sign into Mas' do
        expect(chef_run).to_not run_execute("Sign in to Mas as #{username}")
      end
    end

    context 'signed in as someone else' do
      let(:signed_in_as) { '2@example.com' }
      cached(:chef_run) { converge }

      it 'signs into Mas' do
        expect(chef_run).to run_execute("Sign in to Mas as #{username}")
          .with(command: "mas signin #{username} #{password}")
      end
    end
  end

  context 'the :sign_out action' do
    let(:action) { :sign_out }
    let(:installed) { true }

    context 'signed in' do
      let(:signed_in_as) { 'example@example.com' }
      cached(:chef_run) { converge }

      it 'signs out of Mas' do
        expect(chef_run).to run_execute('Sign out of Mas')
          .with(command: 'mas signout')
      end
    end

    context 'not signed in' do
      let(:signed_in_as) { nil }
      cached(:chef_run) { converge }

      it 'does not sign out of Mas' do
        expect(chef_run).to_not run_execute('Sign out of Mas')
      end
    end
  end
end
