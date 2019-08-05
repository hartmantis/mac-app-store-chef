# frozen_string_literal: true

require 'berkshelf'
require_relative 'spec_helper'

describe Berkshelf::Berksfile.from_options(
  berksfile: File.expand_path('../Berksfile', __dir__)
) do
  it 'indicates all our dependencies are up to date' do
    subject.install
    subject.update
    expect(subject.outdated).to be_empty
  end
end
