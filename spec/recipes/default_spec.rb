# Encoding: UTF-8

require 'spec_helper'

describe 'mac-app-store::default' do
  let(:platform) { { platform: nil, version: nil } }
  let(:overrides) { {} }
  let(:runner) do
    ChefSpec::SoloRunner.new(platform) do |node|
      overrides.each { |k, v| node.set[k] = v }
    end
  end
  let(:chef_run) { runner.converge(described_recipe) }

  context 'OS X platform' do
    let(:platform) { { platform: 'mac_os_x', version: '10.9.2' } }

    shared_examples_for 'any attribute set' do
      it 'installs the required dev tools' do
        expect(chef_run).to include_recipe('build-essential')
      end

      it 'opens the Mac App Store' do
        expect(chef_run).to open_mac_app_store('default')
      end

      it 'notifies the App Store to quit when done' do
        expect(chef_run.mac_app_store('default'))
          .to notify('mac_app_store[default]').to(:quit).delayed
      end
    end

    shared_examples_for 'given an Apple ID' do
      it 'uses the provided Apple ID' do
        expect(chef_run).to open_mac_app_store('default')
          .with(username: overrides[:mac_app_store][:username])
          .with(password: overrides[:mac_app_store][:password])
      end
    end

    shared_examples_for 'given a set of apps to install' do
      it 'installs the specified apps' do
        r = chef_run
        overrides[:mac_app_store][:apps].each do |a|
          if a.is_a?(String)
            expect(r).to install_mac_app_store_app(a)
          else
            expect(r).to install_mac_app_store_app(a[:name])
              .with(bundle_id: a[:bundle_id])
          end
        end
      end
    end

    context 'default attributes' do
      it_behaves_like 'any attribute set'

      it 'installs no apps' do
        expect(chef_run.find_resources(:mac_app_store_app)).to be_empty
      end
    end

    context 'an attribue array of app names only' do
      let(:overrides) { { mac_app_store: { apps: %w(app1 app2) } } }

      context 'no Apple ID given' do
        it_behaves_like 'any attribute set'
        it_behaves_like 'given a set of apps to install'
      end

      context 'an Apple ID given' do
        let(:overrides) do
          o = super()
          o[:mac_app_store][:username] = 'e@example.com'
          o[:mac_app_store][:password] = 'abc123'
          o
        end

        it_behaves_like 'any attribute set'
        it_behaves_like 'given an Apple ID'
        it_behaves_like 'given a set of apps to install'
      end
    end

    context 'an attribute set of mixed array and hash apps' do
      let(:overrides) do
        {
          mac_app_store: {
            apps: [
              'app1',
              { name: 'app2', bundle_id: 'com.example.app2' },
              { name: 'app3' }
            ]
          }
        }
      end

      context 'no Apple ID given' do
        it_behaves_like 'any attribute set'
        it_behaves_like 'given a set of apps to install'
      end

      context 'an Apple ID given' do
        let(:overrides) do
          o = super()
          o[:mac_app_store][:username] = 'e@example.com'
          o[:mac_app_store][:password] = 'abc123'
          o
        end

        it_behaves_like 'any attribute set'
        it_behaves_like 'given an Apple ID'
        it_behaves_like 'given a set of apps to install'
      end
    end
  end

  context 'Ubuntu platform' do
    let(:platform) { { platform: 'ubuntu', version: '14.04' } }

    it 'raises an error' do
      expect { chef_run }.to raise_error(Chef::Exceptions::UnsupportedPlatform)
    end
  end
end
