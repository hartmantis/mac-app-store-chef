# Encoding: UTF-8

require_relative '../spec_helper'
require_relative '../../libraries/provider_mac_app_store_trusted_app'

describe Chef::Provider::MacAppStoreTrustedApp do
  let(:name) { 'com.example.someapp' }
  let(:new_resource) { Chef::Resource::MacAppStoreTrustedApp.new(name, nil) }
  let(:provider) { described_class.new(new_resource, nil) }

  before(:each) do
    allow_any_instance_of(described_class).to receive(:install_sqlite3_gem)
      .and_return(true)
  end

  describe 'SQLITE_VERSION' do
    it 'pins SQLite to 1.x' do
      res = Chef::Provider::MacAppStoreTrustedApp::SQLITE3_VERSION
      expect(res).to eq('~> 1.3')
    end
  end

  describe 'DB_PATH' do
    it 'points to the TCC SQLite file' do
      expected = '/Library/Application Support/com.apple.TCC/TCC.db'
      expect(Chef::Provider::MacAppStoreTrustedApp::DB_PATH).to eq(expected)
    end
  end

  describe '#initialize' do
    it 'installs the SQLite gem' do
      expect_any_instance_of(described_class).to receive(:install_sqlite3_gem)
      provider
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
    let(:query) do
      'INSERT INTO access VALUES(?, ?, ?, ?, ?, ?)'
    end
    let(:db) { double }

    before(:each) do
      allow(db).to receive(:execute).and_return(true)
      allow_any_instance_of(described_class).to receive(:db).and_return(db)
      allow_any_instance_of(described_class).to receive(:row).and_return(row)
    end

    context 'app already with its own row' do
      let(:row) { { 'allowed' => 0 } }

      it 'returns nil' do
        expect(db).not_to receive(:execute)
        expect(provider.send(:'insert!')).to eq(nil)
      end
    end

    context 'app with no row' do
      let(:row) { nil }

      it 'runs an INSERT query' do
        expect(db).to receive(:execute)
          .with(query, 'kTCCServiceAccessibility', name, 0, 1, 0, nil)
          .and_return(true)
        provider.send(:'insert!')
      end
    end

    context 'path to file with no row' do
      let(:name) { '/tmp/app' }

      it 'runs an INSERT query' do
        expect(db).to receive(:execute)
          .with(query, 'kTCCServiceAccessibility', name, 1, 1, 0, nil)
          .and_return(true)
        provider.send(:'insert!')
      end
    end
  end

  describe '#update!' do
    let(:row) { nil }
    let(:query) do
      'UPDATE access SET allowed = 1 WHERE service = ? AND client = ?'
    end
    let(:db) { double }

    before(:each) do
      allow(db).to receive(:execute).and_return(true)
      allow_any_instance_of(described_class).to receive(:db).and_return(db)
      allow_any_instance_of(described_class).to receive(:row).and_return(row)
    end

    context 'app already with its own row' do
      let(:row) { { 'allowed' => 0 } }

      it 'runs an UPDATE query' do
        expect(db).to receive(:execute)
          .with(query, 'kTCCServiceAccessibility', name).and_return(true)
        provider.send(:'update!')
      end
    end

    context 'app with no row' do
      let(:row) { nil }

      it 'returns nil' do
        expect(db).not_to receive(:execute)
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
      let(:row) { { 'allowed' => 1 } }

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
      'SELECT * FROM access WHERE service = ? AND client = ?'
    end
    let(:db) { double }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:db).and_return(db)
      allow(db).to receive(:execute)
        .with(query, 'kTCCServiceAccessibility', name).and_return(query_res)
    end

    context 'no row for the given app' do
      let(:query_res) { [] }

      it 'returns nil' do
        expect(provider.send(:row)).to eq(nil)
      end
    end

    context 'a row for the given app' do
      let(:query_res) { [{ 'key' => 'val' }] }

      it 'returns the row' do
        expect(provider.send(:row)).to eq('key' => 'val')
      end
    end
  end

  describe '#db' do
    let(:db) { double }

    before(:each) do
      expect(SQLite3::Database).to receive(:new)
        .with(Chef::Provider::MacAppStoreTrustedApp::DB_PATH,
              results_as_hash: true)
        .and_return(db)
    end

    it 'returns a SQLite DB instance' do
      expect(provider.send(:db)).to be_an_instance_of(RSpec::Mocks::Double)
    end
  end

  describe '#install_sqlite3_gem' do
    let(:chef_gem) { double(version: true, action: true) }

    before(:each) do
      allow_any_instance_of(described_class).to receive(:chef_gem)
        .with('sqlite3').and_yield
    end

    it 'installs the SQLite gem' do
      p = provider
      allow(p).to receive(:install_sqlite3_gem).and_call_original
      expect(p).to receive(:version).with('~> 1.3')
      expect(p).to receive(:action).with(:install)
      p.send(:install_sqlite3_gem)
    end
  end
end
