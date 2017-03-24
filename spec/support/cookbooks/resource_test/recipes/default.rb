# encoding: utf-8
# frozen_string_literal: true

attrs = node['resource_test']

send(attrs['resource'], attrs['name']) do
  attrs['properties'].to_h.each { |k, v| send(k, v) unless v.nil? }
  action attrs['action'] unless attrs['action'].nil?
end
