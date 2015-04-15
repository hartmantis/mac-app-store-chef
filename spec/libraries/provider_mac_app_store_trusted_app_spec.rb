# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_mac_app_store_trusted_app'

describe Chef::Provider::MacAppStoreTrustedApp do
  let(:name) { 'com.example.someapp' }
  let(:new_resource) { Chef::Resource::MacAppStoreTrustedApp.new(name, nil) }
  let(:provider) { described_class.new(new_resource, nil) }

  describe 'DB_PATH' do
    it 'points to the TCC SQLite file' do
      expected = '/Library/Application\ Support/com.apple.TCC/TCC.db'
      expect(Chef::Provider::MacAppStoreTrustedApp::DB_PATH).to eq(expected)
    end
  end

  describe '#whyrun_supported?' do
    it 'returns true' do
      expect(provider.whyrun_supported?).to eq(true)
    end
  end

  describe '#load_current_resource' do
    let(:created?) { true }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:created?)
        .and_return(created?)
    end

    it 'returns a MacAppStorTrustedeApp resource instance' do
      expected = Chef::Resource::MacAppStoreTrustedApp
      expect(provider.load_current_resource).to be_an_instance_of(expected)
    end

    it 'sets the resource created status' do
      expect(provider.load_current_resource.created?).to eq(true)
    end
  end

  describe '#action_create' do
    let(:created?) { true }
    let(:'insert!') { nil }
    let(:'update!') { nil }

    before(:each) do
      %i(created? insert! update!).each do |m|
        allow_any_instance_of(described_class).to receive(m)
          .and_return(send(m))
      end
    end

    shared_examples_for 'any created state' do
      it 'sets created state to true' do
        expect(new_resource).to receive(:created).with(true)
        provider.action_create
      end
    end

    context 'no entry in the DB' do
      let(:created?) { false }
      let(:'insert!') { nil }

      it_behaves_like 'any created state'

      it 'does a DB INSERT' do
        expect_any_instance_of(described_class).to receive(:'update!')
        expect_any_instance_of(described_class).to receive(:'insert!')
        provider.action_create
      end
    end

    context 'a DB entry without allowed rights' do
      let(:created?) { false }
      let(:'update!') { true }
      let(:'insert!') { nil }

      it_behaves_like 'any created state'

      it 'does a DB UPDATE' do
        expect_any_instance_of(described_class).to receive(:'update!')
        expect_any_instance_of(described_class).not_to receive(:'insert!')
        provider.action_create
      end
    end

    context 'already created' do
      let(:created?) { true }
      let(:'update!') { nil }
      let(:'insert!') { nil }

      it_behaves_like 'any created state'

      it 'does not do anything' do
        expect_any_instance_of(described_class).not_to receive(:'update!')
        expect_any_instance_of(described_class).not_to receive(:'insert!')
        provider.action_create
      end
    end
  end

  describe '#insert!' do
    let(:row) { nil }
    let(:type) { 0 }
    let(:query) do
      'INSERT INTO access VALUES("kTCCServiceAccessibility", ' \
        "\"#{name}\", #{type}, 1, 0, NULL)"
    end

    before(:each) do
      allow_any_instance_of(described_class).to receive(:db_query)
        .with(query).and_return(true)
      allow_any_instance_of(described_class).to receive(:row).and_return(row)
    end

    context 'app already authorized' do
      let(:row) { %w(col1 col2 0 1 0 NULL) }

      it 'runs no queries and returns nil' do
        expect_any_instance_of(described_class).not_to receive(:db_query)
        expect(provider.send(:'insert!')).to eq(nil)
      end
    end

    context 'app in database but not authorized' do
      let(:row) { %w(col1 col2 0 0 0 NULL) }

      it 'runs no queries and returns nil' do
        expect_any_instance_of(described_class).not_to receive(:db_query)
        expect(provider.send(:'insert!')).to eq(nil)
      end
    end

    context 'app not in database' do
      let(:row) { nil }

      it 'runs an INSERT query' do
        expect_any_instance_of(described_class).to receive(:db_query)
          .with(query).and_return(true)
        provider.send(:'insert!')
      end
    end

    context 'app named with a file path and not in database' do
      let(:name) { '/tmp/db.db' }
      let(:type) { 1 }
      let(:row) { nil }

      it 'runs an INSERT query' do
        expect_any_instance_of(described_class).to receive(:db_query)
          .with(query).and_return(true)
        provider.send(:'insert!')
      end
    end
  end

  describe '#update!' do
    let(:row) { nil }
    let(:created?) { false }
    let(:query) do
      'UPDATE access SET allowed = 1 WHERE ' \
        "service = \"kTCCServiceAccessibility\" AND client = \"#{name}\""
    end

    before(:each) do
      allow_any_instance_of(described_class).to receive(:row)
        .and_return(row)
      allow_any_instance_of(described_class).to receive(:created?)
        .and_return(created?)
      allow_any_instance_of(described_class).to receive(:db_query).with(query)
        .and_return(true)
    end

    context 'app already authorized' do
      let(:created?) { true }

      it 'runs no queries and returns nil' do
        expect_any_instance_of(described_class).not_to receive(:db_query)
        expect(provider.send(:'update!')).to eq(nil)
      end
    end

    context 'app in database but not authorized' do
      let(:row) { %w(col1 col2 0 0 0 nil) }
      let(:created?) { false }

      it 'runs an UPDATE query' do
        expect_any_instance_of(described_class).to receive(:db_query)
          .with(query).and_return(true)
        provider.send(:'update!')
      end
    end

    context 'app not in database' do
      let(:row) { nil }

      it 'runs no queries and returns nil' do
        expect_any_instance_of(described_class).not_to receive(:db_query)
        expect(provider.send(:'update!')).to eq(nil)
      end
    end
  end

  describe '#created?' do
    let(:row) { nil }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:row).and_return(row)
    end

    context 'app already allowed' do
      let(:row) { %w(service client 0 1 0 nil) }

      it 'returns true' do
        expect(provider.send(:created?)).to eq(true)
      end
    end

    context 'app not allowed' do
      let(:row) { nil }

      it 'returns false' do
        expect(provider.send(:created?)).to eq(false)
      end
    end
  end

  describe '#row' do
    let(:query_res) { [] }
    let(:query) do
      'SELECT * FROM access WHERE service = "kTCCServiceAccessibility" ' \
        "AND client = \"#{name}\" LIMIT 1"
    end

    before(:each) do
      expect_any_instance_of(described_class).to receive(:db_query)
        .with(query).and_return(query_res)
    end

    context 'no row for the given app' do
      let(:query_res) { [] }

      it 'returns nil' do
        expect(provider.send(:row)).to eq(nil)
      end
    end

    context 'a row for the given app' do
      let(:query_res) { %w(col1 col2) }

      it 'returns the row' do
        expect(provider.send(:row)).to eq(query_res)
      end
    end
  end

  describe '#db_query' do
    let(:db_path) { '/Library/Application\ Support/com.apple.TCC/TCC.db' }
    let(:query) { nil }
    let(:query_res) { '' }
    let(:shell_out) { double(stdout: query_res) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:'shell_out!')
        .with("sqlite3 #{db_path} '#{query}'").and_return(shell_out)
    end

    context 'a successful query with a result' do
      let(:query) { 'SELECT * FROM access LIMIT 1' }
      let(:query_res) { 'thing1|thing2' }

      it 'returns the query result' do
        expect(provider.send(:db_query, query)).to eq(query_res.split('|'))
      end
    end

    context 'a successful query with no result' do
      let(:query) { 'SELECT * FROM access LIMIT 1' }
      let(:query_res) { '' }

      it 'returns an empty array' do
        expect(provider.send(:db_query, query)).to eq([])
      end
    end

    context 'a query that results in an error' do
      let(:query) { 'SELECT * FROM access LIMIT 1' }

      before(:each) do
        expect_any_instance_of(described_class).to receive(:'shell_out!')
          .with("sqlite3 #{db_path} '#{query}'")
          .and_raise(Mixlib::ShellOut::ShellCommandFailed)
      end

      it 'raises an error' do
        expect { provider.send(:db_query, query) }.to raise_error
      end
    end
  end
end
