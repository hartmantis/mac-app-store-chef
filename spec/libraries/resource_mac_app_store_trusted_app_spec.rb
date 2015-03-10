# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_mac_app_store_trusted_app'

describe Chef::Resource::MacAppStoreTrustedApp do
  let(:name) { 'com.example.someapp' }
  let(:resource) { described_class.new(name, nil) }

  describe '#initialize' do
    it 'sets the correct resource name' do
      exp = :mac_app_store_trusted_app
      expect(resource.instance_variable_get(:@resource_name)).to eq(exp)
    end

    it 'sets the correct supported actions' do
      expected = [:nothing, :create]
      expect(resource.instance_variable_get(:@allowed_actions)).to eq(expected)
    end

    it 'defaults the created state to nil' do
      expect(resource.instance_variable_get(:@created)).to eq(nil)
    end
  end

  [:created, :created?].each do |m|
    describe "##{m}" do
      context 'default unknown created status' do
        it 'returns nil' do
          expect(resource.send(m)).to eq(nil)
        end
      end

      context 'trusted app created' do
        it 'returns true' do
          r = resource
          r.instance_variable_set(:@created, true)
          expect(r.send(m)).to eq(true)
        end
      end

      context 'trusted app not created' do
        it 'returns false' do
          r = resource
          r.instance_variable_set(:@created, false)
          expect(resource.send(m)).to eq(false)
        end
      end
    end
  end
end
