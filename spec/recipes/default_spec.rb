# Encoding: UTF-8

require 'spec_helper'

describe 'mac-app-store::default' do
  let(:platform) { { platform: nil, version: nil } }
  let(:overrides) { {} }
  let(:runner) do
    ChefSpec::ServerRunner.new(platform) do |node|
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
    end

    context 'default attributes' do
      it_behaves_like 'any attribute set'

      it 'does nothing' do
        expect(chef_run.find_resources(:mac_app_store_app)).to be_empty
      end
    end

    context 'an attribue set of apps' do
      let(:overrides) do
        {
          mac_app_store: {
            apps: {
              'app1' => 'com.example.app1',
              'app2' => 'com.example.app2'
            }
          }
        }
      end

      it_behaves_like 'any attribute set'

      it 'installs the apps' do
        r = chef_run
        %w(app1 app2).each do |a|
          expect(r).to install_mac_app_store_app(a)
            .with(app_id: "com.example.#{a}")
        end
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
