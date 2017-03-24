# encoding: utf-8
# frozen_string_literal: true

require_relative '../mac_app_store_app'

shared_context 'resources::mac_app_store_app::mac_os_x' do
  include_context 'resources::mac_app_store_app'

  let(:platform) { 'mac_os_x' }

  shared_examples_for 'any MacOS platform' do
    it_behaves_like 'any platform'

    context 'the :install action' do
      include_context description

      context 'app not already installed' do
        include_context description

        context 'all default properties' do
          include_context description

          it 'installs the app' do
            expect(chef_run).to run_execute("Install #{name} with Mas")
              .with(command: "mas install #{app_id_for?}")
          end
        end

        context 'an overridden app_name property' do
          include_context description

          it 'installs the app with the correct name' do
            expect(chef_run).to run_execute("Install #{app_name} with Mas")
              .with(command: "mas install #{app_id_for?}")
          end
        end

        context 'an overridden use_rtun property' do
          include_context description

          it 'installs the app using RtUN' do
            expect(chef_run).to run_execute("Install #{name} with Mas").with(
              command: "reattach-to-user-namespace mas install #{app_id_for?}"
            )
          end
        end

        context 'app non-existent' do
          include_context description

          it 'raises an error' do
            exp = Chef::Resource::MacAppStoreApp::Exceptions::InvalidAppName
            expect { chef_run }.to raise_error(exp)
          end
        end
      end

      context 'app already installed' do
        include_context description

        it 'does not install the app' do
          expect(chef_run).to_not run_execute("Install #{name} with Mas")
        end
      end
    end

    context 'the :upgrade action' do
      include_context description

      context 'app not already installed' do
        include_context description

        context 'all default properties' do
          include_context description

          it 'installs the app' do
            expect(chef_run).to run_execute("Upgrade #{name} with Mas")
              .with(command: "mas install #{app_id_for?}")
          end
        end

        context 'an overridden app_name property' do
          include_context description

          it 'upgrades the app with the correct name' do
            expect(chef_run).to run_execute("Upgrade #{app_name} with Mas")
              .with(command: "mas install #{app_id_for?}")
          end
        end

        context 'an overridden use_rtun property' do
          include_context description

          it 'upgrades the app using RtUN' do
            expect(chef_run).to run_execute("Upgrade #{name} with Mas").with(
              command: "reattach-to-user-namespace mas install #{app_id_for?}"
            )
          end
        end
      end

      context 'app non-existent' do
        include_context description

        it 'raises an error' do
          expected = Chef::Resource::MacAppStoreApp::Exceptions::InvalidAppName
          expect { chef_run }.to raise_error(expected)
        end
      end

      context 'app installed and upgradable' do
        include_context description

        context 'all default properties' do
          include_context description

          it 'upgrades the app' do
            expect(chef_run).to run_execute("Upgrade #{name} with Mas")
              .with(command: "mas install #{app_id_for?}")
          end
        end

        context 'an overridden app_name property' do
          include_context description

          it 'upgrades the app with the correct name' do
            expect(chef_run).to run_execute("Upgrade #{app_name} with Mas")
              .with(command: "mas install #{app_id_for?}")
          end
        end

        context 'an overridden use_rtun property' do
          include_context description

          it 'upgrades the app using RtUN' do
            expect(chef_run).to run_execute("Upgrade #{name} with Mas").with(
              command: "reattach-to-user-namespace mas install #{app_id_for?}"
            )
          end
        end
      end

      context 'app already installed' do
        include_context description

        it 'does not upgrade the app' do
          expect(chef_run).to_not run_execute("Upgrade #{name} with Mas")
        end
      end
    end
  end
end
