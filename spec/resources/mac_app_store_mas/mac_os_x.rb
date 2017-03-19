# encoding: utf-8
# frozen_string_literal: true

require_relative '../mac_app_store_mas'

shared_context 'resources::mac_app_store_mas::mac_os_x' do
  include_context 'resources::mac_app_store_mas'

  let(:platform) { 'mac_os_x' }

  shared_examples_for 'any MacOS platform' do
    it_behaves_like 'any platform'

    context 'the :install action' do
      include_context description

      context 'all default properties' do
        include_context description

        context 'not already installed' do
          include_context description

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
          include_context description

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

      context 'an overridden source property' do
        include_context description

        context 'not already installed' do
          include_context description

          it 'includes the homebrew default recipe' do
            expect(chef_run).to include_recipe('homebrew')
          end

          it 'installs Mas via Homebrew' do
            expect(chef_run).to install_homebrew_package('mas')
          end
        end

        context 'already installed' do
          include_context description

          it 'does not include the homebrew default recipe' do
            expect(chef_run).to_not include_recipe('homebrew')
          end

          it 'does not install Mas via Homebrew' do
            expect(chef_run).to_not install_homebrew_package('mas')
          end
        end
      end

      context 'a missing username property' do
        include_context description

        it 'raises an error' do
          expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
        end
      end

      context 'a missing password property' do
        include_context description

        it 'raises an error' do
          expect { chef_run }.to raise_error(Chef::Exceptions::ValidationFailed)
        end
      end
    end

    context 'the :upgrade action' do
      include_context description

      context 'all default properties' do
        include_context description

        context 'not already installed' do
          include_context description

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
          include_context description

          it 'does not download mas-cli.zip from GitHub' do
            expect(chef_run).to_not create_remote_file(
              "#{Chef::Config[:file_cache_path]}/mas-cli.zip"
            )
          end

          it 'does not unzip mas-cli.zip into place' do
            expect(chef_run).to_not run_execute('Extract Mas-CLI zip file')
          end
        end

        context 'installed and upgradable' do
          include_context description

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
      end

      context 'an overridden source property' do
        include_context description

        context 'not already installed' do
          include_context description

          it 'includes the homebrew default recipe' do
            expect(chef_run).to include_recipe('homebrew')
          end

          it 'upgrades Mas via Homebrew' do
            expect(chef_run).to upgrade_homebrew_package('mas')
          end
        end

        context 'already installed' do
          include_context description

          it 'does not include the homebrew default recipe' do
            expect(chef_run).to_not include_recipe('homebrew')
          end

          it 'does not upgrade Mas via Homebrew' do
            expect(chef_run).to_not upgrade_homebrew_package('mas')
          end
        end

        context 'installed and upgradable' do
          include_context description

          it 'includes the homebrew default recipe' do
            expect(chef_run).to include_recipe('homebrew')
          end

          it 'upgrades Mas via Homebrew' do
            expect(chef_run).to upgrade_homebrew_package('mas')
          end
        end
      end
    end

    context 'the :remove action' do
      include_context description

      context 'already installed' do
        include_context description

        context 'all default properties' do
          include_context description

          it 'deletes the mas file' do
            expect(chef_run).to delete_file('/usr/local/bin/mas')
          end
        end

        context 'an overridden source property' do
          include_context description

          it 'includes the homebrew default recipe' do
            expect(chef_run).to include_recipe('homebrew')
          end

          it 'removes Mas via Homebrew' do
            expect(chef_run).to remove_homebrew_package('mas')
          end
        end
      end

      context 'not already installed' do
        include_context description

        context 'all default properties' do
          include_context description

          it 'does not delete the mas file' do
            expect(chef_run).to_not delete_file('/usr/local/bin/mas')
          end
        end

        context 'an overridden source property' do
          include_context description

          it 'does not include the homebrew default recipe' do
            expect(chef_run).to_not include_recipe('homebrew')
          end

          it 'does not remove Mas via Homebrew' do
            expect(chef_run).to_not remove_homebrew_package('mas')
          end
        end
      end
    end

    context 'the :sign_in action' do
      include_context description

      context 'already installed' do
        include_context description

        context 'not already signed in' do
          include_context description

          context 'all default properties' do
            include_context description

            it 'signs into Mas with the correct system user' do
              expect(chef_run).to run_execute("Sign in to Mas as #{username}")
                .with(command: "mas signin '#{username}' '#{password}'",
                      user: getlogin,
                      returns: [0, 6],
                      sensitive: true)
            end
          end

          context 'an overridden system_user property' do
            include_context description

            it 'signs into Mas with the correct user' do
              expect(chef_run).to run_execute("Sign in to Mas as #{username}")
                .with(command: "mas signin '#{username}' '#{password}'",
                      user: 'testme',
                      returns: [0, 6],
                      sensitive: true)
            end
          end

          context 'an overridden use_rtun property' do
            include_context description

            it 'ensures RtUN is installed' do
              expect(chef_run).to include_recipe('reattach-to-user-namespace')
            end

            it 'signs into Mas using RtUN' do
              expect(chef_run).to run_execute("Sign in to Mas as #{username}")
                .with(command: 'reattach-to-user-namespace mas signin ' \
                               "'#{username}' '#{password}'",
                      user: getlogin,
                      returns: [0, 6],
                      sensitive: true)
            end
          end
        end

        context 'already signed in' do
          include_context description

          it 'does not sign into Mas' do
            expect(chef_run).to_not run_execute("Sign in to Mas as #{username}")
          end
        end

        context 'signed in as someone else' do
          include_context description

          it 'signs into Mas' do
            expect(chef_run).to run_execute("Sign in to Mas as #{username}")
              .with(command: "mas signin '#{username}' '#{password}'",
                    user: getlogin,
                    returns: [0, 6],
                    sensitive: true)
          end
        end

        context 'a missing username property' do
          include_context description

          it 'raises an error' do
            expected = Chef::Exceptions::ValidationFailed
            expect { chef_run }.to raise_error(expected)
          end
        end

        context 'a missing password property' do
          include_context description

          it 'raises an error' do
            expected = Chef::Exceptions::ValidationFailed
            expect { chef_run }.to raise_error(expected)
          end
        end
      end

      context 'not already installed' do
        it 'does an as-yet undecided thing' do
          pending
          expect(true).to eq(false)
        end
      end
    end

    context 'the :sign_out action' do
      include_context description

      context 'already installed' do
        include_context description

        context 'already signed in' do
          include_context description

          context 'all default properties' do
            include_context description

            it 'signs out of Mas with the correct system user' do
              expect(chef_run).to run_execute('Sign out of Mas')
                .with(command: 'mas signout', user: getlogin)
            end
          end

          context 'an overridden system_user property' do
            include_context description

            it 'signs out of Mas with the correct system user' do
              expect(chef_run).to run_execute('Sign out of Mas')
                .with(command: 'mas signout', user: 'testme')
            end
          end

          context 'an overridden use_rtun property' do
            include_context description

            it 'ensures RtUN is installed' do
              expect(chef_run).to include_recipe('reattach-to-user-namespace')
            end

            it 'signs out of Mas using RtUN' do
              expect(chef_run).to run_execute('Sign out of Mas')
                .with(command: 'reattach-to-user-namespace mas signout')
            end
          end
        end

        context 'not already signed in' do
          include_context description

          it 'does not sign out of Mas' do
            expect(chef_run).to_not run_execute('Sign out of Mas')
          end
        end
      end

      context 'not already installed' do
        it 'does an as-yet undecided thing' do
          pending
          expect(true).to eq(false)
        end
      end
    end

    context 'the :upgrade_apps action' do
      include_context description

      context 'already installed' do
        include_context description

        context 'app upgrades available' do
          include_context description

          context 'all default properties' do
            include_context description

            it 'runs a Mas upgrade' do
              expect(chef_run).to run_execute('Upgrade all installed apps')
                .with(command: 'mas upgrade', user: getlogin)
            end
          end

          context 'an overridden use_rtun property' do
            include_context description

            it 'ensures RtUN is installed' do
              expect(chef_run).to include_recipe('reattach-to-user-namespace')
            end

            it 'runs a Mas upgrade using RtUN' do
              expect(chef_run).to run_execute('Upgrade all installed apps')
                .with(command: 'reattach-to-user-namespace mas upgrade',
                      user: getlogin)
            end
          end
        end

        context 'no app upgrades available' do
          include_context description

          it 'does not run a Mas upgrade' do
            expect(chef_run).to_not run_execute('Upgrade all installed apps')
          end
        end
      end

      context 'not already installed' do
        include_context description

        it 'does an as-yet undecided thing' do
          pending
          expect(true).to eq(false)
        end
      end
    end
  end
end
