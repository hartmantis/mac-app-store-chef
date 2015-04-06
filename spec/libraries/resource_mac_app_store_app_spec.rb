# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_mac_app_store_app'

describe Chef::Resource::MacAppStoreApp do
  let(:app_name) { 'Some App' }
  let(:timeout) { nil }
  let(:resource) do
    r = described_class.new(app_name, nil)
    r.timeout(timeout)
    r
  end

  shared_examples_for 'an invalid configuration' do
    it 'raises an exception' do
      expect { resource }.to raise_error(Chef::Exceptions::ValidationFailed)
    end
  end

  describe '#initialize' do
    it 'sets the correct resource name' do
      exp = :mac_app_store_app
      expect(resource.instance_variable_get(:@resource_name)).to eq(exp)
    end

    it 'sets the correct supported actions' do
      expected = [:nothing, :install]
      expect(resource.instance_variable_get(:@allowed_actions)).to eq(expected)
    end

    it 'defaults the installed state to nil' do
      expect(resource.instance_variable_get(:@installed)).to eq(nil)
    end
  end

  %i(installed installed?).each do |m|
    describe "##{m}" do
      context 'default unknown installed status' do
        it 'returns nil' do
          expect(resource.send(m)).to eq(nil)
        end
      end

      context 'app installed' do
        it 'returns true' do
          r = resource
          r.instance_variable_set(:@installed, true)
          expect(r.send(m)).to eq(true)
        end
      end

      context 'app not installed' do
        it 'returns false' do
          r = resource
          r.instance_variable_set(:@installed, false)
          expect(resource.send(m)).to eq(false)
        end
      end
    end
  end

  describe '#timeout' do
    context 'no override' do
      it 'returns the default' do
        expect(resource.timeout).to eq(600)
      end
    end

    context 'a valid override' do
      let(:timeout) { 1 }

      it 'returns the override' do
        expect(resource.timeout).to eq(1)
      end
    end

    context 'an invalid override' do
      let(:timeout) { :thing }

      it_behaves_like 'an invalid configuration'
    end
  end
end
