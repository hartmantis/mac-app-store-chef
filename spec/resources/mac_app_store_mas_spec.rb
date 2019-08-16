# frozen_string_literal: true

require_relative '../spec_helper'

describe 'mac_app_store_mas' do
  step_into :mac_app_store_mas

  default_attributes['test'] = {}

  recipe do
    mac_app_store_mas do
      node['test'].each { |k, v| send(k, v) }
    end
  end

  context 'the default action' do
    it { is_expected.to install_mac_app_store_mas('default') }
    it { is_expected.to sign_in_mac_app_store_mas('default') }
  end

  %i[install upgrade].each do |act|
    context "the :#{act} action" do
      default_attributes['test']['action'] = act

      context 'all default properties' do
        it { is_expected.to send("#{act}_homebrew_package, 'mas').with(version: nil) }
      end

      context 'an overridden version property' do
        default_attributes['test']['version'] = '1.2.3'

        it { is_expected.to send("#{act}_homebrew_package, 'mas').with(version: '1.2.3') }
      end
    end
  end

  context 'the :remove action' do
    default_attributes['test']['action'] = :remove

    it { is_expected.to remove_homebrew_package('mas') }
  end

  context 'the :upgrade_apps action' do
    default_attributes['test']['action'] = :upgrade_apps

    context 'upgrades available' do
      it { is_expected.to run_execute('Upgrade all installed apps').with(command: 'mas upgrade') }
    end

    context 'no upgrades available' do
      it { is_expected.to_not run_execute('Upgrade all installed apps').with(command: 'mas upgrade') }
    end
  end
end
