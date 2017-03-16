# encoding: utf-8
# frozen_string_literal: true

require_relative 'spec_helper'

shared_context 'resources' do
  %i(resource name platform platform_version action).each { |p| let(p) { nil } }
  let(:properties) { {} }
  let(:runner) do
    ChefSpec::SoloRunner.new(
      step_into: resource, platform: platform, version: platform_version
    ) do |node|
      %i(resource name action).each do |p|
        next if send(p).nil?
        node.default['resource_test'][p] = send(p)
      end
      properties.each do |k, v|
        next if v.nil?
        node.default['resource_test']['properties'][k] = v
      end
    end
  end
  let(:converge) { runner.converge('resource_test') }
  let(:chef_run) { converge }
end
