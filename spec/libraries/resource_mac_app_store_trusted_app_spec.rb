# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/resource_mac_app_store_trusted_app'

describe Chef::Resource::MacAppStoreTrustedApp do
  let(:name) { 'com.example.someapp' }
  let(:compile_time) { nil }
  let(:resource) do
    r = described_class.new(name, nil)
    r.compile_time(compile_time)
    r
  end

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

  describe '#compile_time' do
    context 'no override' do
      it 'defaults to false' do
        expect(resource.compile_time).to eq(false)
      end
    end

    context 'a valid override' do
      let(:compile_time) { true }

      it 'returns the override' do
        expect(resource.compile_time).to eq(true)
      end
    end

    context 'an invalid override' do
      let(:compile_time) { :thing }

      it 'raises an error' do
        expected = Chef::Exceptions::ValidationFailed
        expect { resource.compile_time }.to raise_error(expected)
      end
    end
  end

  describe '#after_created' do
    before(:each) do
      allow(described_class).to receive(:run_action).and_return(true)
    end

    context 'compile_time disabled' do
      let(:compile_time) { false }

      it 'runs no actions' do
        r = resource
        expect(r).not_to receive(:run_action)
        r.after_created
      end
    end

    context 'compile_time enabled' do
      let(:compile_time) { true }

      it 'runs actions immediately' do
        r = resource
        expect(r).to receive(:run_action).with(:create)
        r.after_created
      end
    end
  end
end
