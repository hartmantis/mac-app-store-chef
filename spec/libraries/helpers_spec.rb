# Encoding: UTF-8

require 'ax_elements'
require_relative '../spec_helper'
require_relative '../../libraries/helpers'

describe MacAppStoreCookbook::Helpers do
  let(:app_name) { 'Some App' }

  before(:each) do
    allow(described_class).to receive(:sleep).and_return(true)
  end

  describe '#install!' do
    let(:installed?) { false }
    let(:press) { 'a button press' }
    let(:app_page_button) { 'an install button' }
    let(:wait_for_install) { 'a wait' }

    before(:each) do
      %i(installed? press app_page_button wait_for_install).each do |m|
        allow(described_class).to receive(m).and_return(send(m))
      end
      allow(described_class).to receive(:fail_unless_purchased)
        .with(app_name).and_return(true)
    end

    shared_examples_for 'any circumstances' do
      it 'bails out if the app is not purchased' do
        expect(described_class).to receive(:fail_unless_purchased)
          .with(app_name)
        described_class.install!(app_name, 10)
      end
    end

    context 'app not installed' do
      let(:installed?) { false }

      it_behaves_like 'any circumstances'

      it 'presses the install button' do
        expect(described_class).to receive(:app_page_button).with(app_name)
        expect(described_class).to receive(:press).with(app_page_button)
        described_class.install!(app_name, 10)
      end

      it 'waits for the install to finish' do
        expect(described_class).to receive(:wait_for_install)
          .with(app_name, 10)
        described_class.install!(app_name, 10)
      end
    end

    context 'app already installed' do
      let(:installed?) { true }

      it_behaves_like 'any circumstances'

      it 'returns nil' do
        expect(described_class.install!(app_name, 10)).to eq(nil)
      end

      it 'presses no buttons' do
        expect(described_class).not_to receive(:press)
        described_class.install!(app_name, 10)
      end
    end
  end

  describe '#wait_for_install' do
    let(:timeout) { 10 }
    let(:app_page) { 'an app page' }
    let(:wait_for) { nil }

    before(:each) do
      allow(described_class).to receive(:app_page).with(app_name)
        .and_return(app_page)
      allow(described_class).to receive(:wait_for)
        .with(:button,
              app_page,
              description: /^(Installed,|Open,)/,
              timeout: timeout).and_return(wait_for)
    end

    context 'a successful install' do
      let(:wait_for) { true }

      it 'returns nil' do
        expect(described_class.wait_for_install(app_name, timeout)).to eq(nil)
      end
    end

    context 'an install timeout' do
      let(:wait_for) { nil }

      it 'raises an error' do
        expected = MacAppStoreCookbook::Exceptions::Timeout
        expect { described_class.wait_for_install(app_name, timeout) }
          .to raise_error(expected)
      end
    end
  end

  describe '#installed?' do
    let(:installed) { false }
    let(:app_page_button) do
      double(description: installed ? 'Open, Thing' : 'Install, Thing')
    end

    before(:each) do
      allow(described_class).to receive(:app_page_button).with(app_name)
        .and_return(app_page_button)
    end

    context 'app not installed' do
      let(:installed) { false }

      it 'returns false' do
        expect(described_class.installed?(app_name)).to eq(false)
      end
    end

    context 'app installed' do
      let(:installed) { true }

      it 'returns true' do
        expect(described_class.installed?(app_name)).to eq(true)
      end
    end
  end

  describe '#latest_version' do
    let(:version) { '1.2.3' }
    let(:app_page) do
      double(
        main_window: double(static_text: double(parent: double(
          static_text: double(value: version)))
        )
      )
    end

    before(:each) do
      allow(described_class).to receive(:app_page).and_return(app_page)
    end

    it 'returns the version number' do
      expect(described_class.latest_version(app_name)).to eq('1.2.3')
    end
  end

  describe '#app_page_button' do
    let(:button) { 'i am a button' }
    let(:app_page) do
      double(main_window: double(web_area: double(group: double(group: double(
        button: button
      )))))
    end

    before(:each) do
      allow(described_class).to receive(:app_page).and_return(app_page)
    end

    it 'returns the install button' do
      expect(described_class.app_page_button(app_name)).to eq(button)
    end
  end

  describe '#app_page' do
    let(:already_there?) { false }
    let(:press) { true }
    let(:row) { double(link: 'link') }
    let(:wait_for) { nil }
    let(:app_store) do
      double(
        main_window: double(
          web_area: double(
            description: already_there? ? app_name : 'Elsewhere'
          )
        )
      )
    end

    before(:each) do
      [:press, :app_store].each do |m|
        allow(described_class).to receive(m).and_return(send(m))
      end
      allow(described_class).to receive(:row).with(app_name).and_return(row)
      allow(described_class).to receive(:wait_for)
        .with(:web_area, app_store.main_window, description: app_name)
        .and_return(wait_for)
    end

    context 'normal conditions, no timeouts' do
      let(:wait_for) { true }

      it 'presses the app link' do
        expect(described_class).to receive(:press).with('link')
        described_class.app_page(app_name)
      end

      it 'returns the app store object' do
        expect(described_class.app_page(app_name)).to eq(app_store)
      end
    end

    context 'app page loading timeout' do
      let(:wait_for) { nil }

      it 'raises an error' do
        expected = MacAppStoreCookbook::Exceptions::Timeout
        expect { described_class.app_page(app_name) }.to raise_error(expected)
      end
    end

    context 'App Store already at the right page' do
      let(:already_there?) { true }

      it 'does nothing to alter the App Store state' do
        expect(described_class).not_to receive(:press)
        expect(described_class).not_to receive(:wait_for)
        described_class.app_page(app_name)
      end
    end
  end

  describe '#fail_unless_purchased' do
    let(:purchased?) { true }

    before(:each) do
      allow(described_class).to receive(:purchased?).and_return(purchased?)
    end

    context 'purchased app' do
      let(:purchased?) { true }

      it 'returns true' do
        expect(described_class.fail_unless_purchased(app_name)).to eq(true)
      end
    end

    context 'not purchased app' do
      let(:purchased?) { false }

      it 'raises an error' do
        expected = MacAppStoreCookbook::Exceptions::AppNotPurchased
        expect { described_class.fail_unless_purchased(app_name) }
          .to raise_error(expected)
      end
    end
  end

  describe '#purchased?' do
    let(:purchased) { false }
    let(:on_app_page) { false }
    let(:installed) { false }
    let(:app_store) do
      double(
        main_window: double(
          web_area: double(
            description: on_app_page ? app_name : 'other'
          )
        )
      )
    end
    let(:button_description) do
      if on_app_page
        if purchased
          installed ? "Open, #{app_name}" : "Install, #{app_name}"
        else
          "Buy, #{app_name}, $3.99"
        end
      end
    end
    let(:app_page_button) do
      double(description: button_description)
    end
    let(:row) { purchased ? 'a row' : nil }

    before(:each) do
      allow(described_class).to receive(:app_store).and_return(app_store)
      allow(described_class).to receive(:app_page_button).with(app_name)
        .and_return(app_page_button)
      allow(described_class).to receive(:row).with(app_name).and_return(row)
    end

    context 'already on the app page, past the Purchases list' do
      let(:on_app_page) { true }

      context 'app already installed' do
        let(:purchased) { true }
        let(:installed) { true }

        it 'returns true' do
          expect(described_class.purchased?(app_name)).to eq(true)
        end
      end

      context 'app not installed' do
        let(:purchased) { true }
        let(:installed) { false }

        it 'returns true' do
          expect(described_class.purchased?(app_name)).to eq(true)
        end
      end

      context 'app not purchased' do
        let(:purchased) { false }
        let(:installed) { false }

        it 'returns false' do
          expect(described_class.purchased?(app_name)).to eq(false)
        end
      end
    end

    context 'on the Purchases list page' do
      let(:on_app_page) { false }

      context 'app already installed' do
        let(:purchased) { true }
        let(:installed) { true }

        it 'returns true' do
          expect(described_class.purchased?(app_name)).to eq(true)
        end
      end

      context 'app not installed' do
        let(:purchased) { true }
        let(:installed) { false }

        it 'returns true' do
          expect(described_class.purchased?(app_name)).to eq(true)
        end
      end

      context 'app not purchased' do
        let(:purchased) { false }
        let(:installed) { false }

        it 'returns false' do
          expect(described_class.purchased?(app_name)).to eq(false)
        end
      end
    end
  end

  describe '#row' do
    let(:search) { nil }
    let(:main_window) { double }
    let(:purchases) { double(main_window: main_window) }

    before(:each) do
      allow(described_class).to receive(:purchases).and_return(purchases)
      allow(main_window).to receive(:search)
        .with(:row, link: { title: app_name }).and_return(search)
    end

    context 'a purchased app' do
      let(:search) { 'some row' }

      it 'returns the app row' do
        expect(described_class.row(app_name)).to eq('some row')
      end
    end

    context 'a non-purchased app' do
      let(:search) { nil }

      it 'returns nil' do
        expect(described_class.row(app_name)).to eq(nil)
      end
    end
  end

  describe '#purchases' do
    let(:already_there?) { false }
    let(:signed_in?) { true }
    let(:wait_for) { nil }
    let(:main_window) do
      double(
        web_area: double(
          description: already_there? ? 'Purchases' : 'Elsewhere'
        )
      )
    end
    let(:app_store) { double(main_window: main_window, ancestry: []) }

    before(:each) do
      %i(set_focus_to select_menu_item).each do |m|
        allow(described_class).to receive(m).and_return(m)
      end
      %i(signed_in? app_store).each do |m|
        allow(described_class).to receive(m).and_return(send(m))
      end
      allow(described_class).to receive(:wait_for)
        .with(:web_area, main_window, description: 'Purchases')
        .and_return(wait_for)
    end

    context 'user not signed in' do
      let(:signed_in?) { false }

      it 'raises an exception' do
        expected = MacAppStoreCookbook::Exceptions::UserNotSignedIn
        expect { described_class.purchases }.to raise_error(expected)
      end
    end

    context 'user signed in, no timeout' do
      let(:wait_for) { true }
      let(:signed_in?) { true }

      it 'selects Purchases from the dropdown menu'do
        expect(described_class).to receive(:select_menu_item)
          .with(app_store, 'Store', 'Purchases')
        described_class.purchases
      end

      it 'waits for the window group to load' do
        expect(described_class).to receive(:wait_for)
          .with(:web_area, app_store.main_window, description: 'Purchases')
          .and_return(true)
        described_class.purchases
      end

      it 'returns the App Store object' do
        expect(described_class.purchases).to eq(app_store)
      end
    end

    context 'purchases list loading timeout' do
      let(:wait_for) { nil }

      it 'raises an exception' do
        expected = MacAppStoreCookbook::Exceptions::Timeout
        expect { described_class.purchases }.to raise_error(expected)
      end
    end

    context 'App Store already at the Purchases page' do
      let(:already_there?) { true }

      it 'does nothing to modify App Store state' do
        expect(described_class).not_to receive(:select_menu_item)
        expect(described_class).not_to receive(:wait_for)
        described_class.purchases
      end
    end
  end

  describe '#sign_out!' do
    let(:signed_in?) { true }
    let(:app_store) { 'fake app store' }

    before(:each) do
      %i(signed_in? app_store).each do |m|
        allow(described_class).to receive(m).and_return(send(m))
      end
      allow(described_class).to receive(:select_menu_item).and_return(true)
    end

    context 'user not signed in' do
      let(:signed_in?) { false }

      it 'returns without doing anything' do
        expect(described_class).not_to receive(:select_menu_item)
        described_class.sign_out!
      end
    end

    context 'user signed in' do
      let(:signed_in?) { true }

      it 'signs the user out' do
        expect(described_class).to receive(:select_menu_item)
          .with(app_store, 'Store', 'Sign Out')
        described_class.sign_out!
      end
    end
  end

  describe '#sign_in!' do
    let(:username) { 'some_user' }
    let(:password) { 'some_password' }
    let(:username_field) { 'a username text box' }
    let(:password_field) { 'a password text box' }
    let(:sign_in_button) { 'a sign in button' }
    let(:signed_in?) { false }
    let(:current_user?) { nil }

    before(:each) do
      %i(
        username_field
        password_field
        sign_in_button
        signed_in?
        current_user?
      ).each do |m|
        allow(described_class).to receive(m).and_return(send(m))
      end
      %i(sign_in_menu set press wait_for_sign_in).each do |m|
        allow(described_class).to receive(m).and_return(true)
      end
    end

    context 'user already signed in' do
      let(:signed_in?) { true }
      let(:current_user?) { username }

      it 'returns immediately' do
        expect(described_class).not_to receive(:sign_in_menu)
        described_class.sign_in!(username, password)
      end
    end

    context 'user not signed in' do
      let(:signed_in?) { false }

      it 'does not sign out' do
        expect(described_class).not_to receive(:sign_out!)
        described_class.sign_in!(username, password)
      end

      it 'selects the Sign In menu' do
        expect(described_class).to receive(:sign_in_menu)
        described_class.sign_in!(username, password)
      end

      it 'enters Apple ID information' do
        expect(described_class).to receive(:set).with(username_field, username)
        described_class.sign_in!(username, password)
      end

      it 'enters Password information' do
        expect(described_class).to receive(:set).with(password_field, password)
        described_class.sign_in!(username, password)
      end

      it 'presses the Sign In button' do
        expect(described_class).to receive(:press).with(sign_in_button)
        described_class.sign_in!(username, password)
      end

      it 'waits for sign in to finish' do
        expect(described_class).to receive(:wait_for_sign_in)
        described_class.sign_in!(username, password)
      end
    end

    context 'a different user signed in' do
      let(:signed_in?) { true }
      let(:current_user?) { 'anotheruser' }

      it 'signs out' do
        expect(described_class).to receive(:sign_out!)
        described_class.sign_in!(username, password)
      end
    end
  end

  describe '#wait_for_sign_in' do
    let(:wait_for) { true }
    let(:menu_bar_item) { 'an mbi' }
    let(:app_store) { double }

    before(:each) do
      expect(app_store).to receive(:menu_bar_item).with(title: 'Store')
        .and_return(menu_bar_item)
      expect(described_class).to receive(:app_store).and_return(app_store)
      expect(described_class).to receive(:wait_for)
        .with(:menu_item,
              menu_bar_item,
              title: 'Sign Out').and_return(wait_for)
    end

    context 'successful sign in' do
      let(:wait_for) { true }

      it 'raises no errors' do
        expect { described_class.wait_for_sign_in }.not_to raise_error
      end
    end

    context 'sign in timeout' do
      let(:wait_for) { nil }

      it 'raises an error' do
        expected = MacAppStoreCookbook::Exceptions::Timeout
        expect { described_class.wait_for_sign_in }.to raise_error(expected)
      end
    end
  end

  describe '#sign_in_button' do
    let(:button) { 'a button' }
    let(:sheet) { double }
    let(:sign_in_menu) { double(main_window: double(sheet: sheet)) }

    before(:each) do
      allow(sheet).to receive(:button).with(title: 'Sign In')
        .and_return(button)
      allow(described_class).to receive(:sign_in_menu).and_return(sign_in_menu)
    end

    it 'returns the Sign In button' do
      expect(described_class.sign_in_button).to eq(button)
    end
  end

  describe '#username_field' do
    let(:text_field) { 'text field' }
    let(:static_text) { 'static text' }
    let(:sheet) { double }
    let(:sign_in_menu) { double(main_window: double(sheet: sheet)) }

    before(:each) do
      allow(sheet).to receive(:static_text).with(value: 'Apple ID ')
        .and_return(static_text)
      allow(sheet).to receive(:text_field).with(title_ui_element: static_text)
        .and_return(text_field)
      allow(described_class).to receive(:sign_in_menu).and_return(sign_in_menu)
    end

    it 'returns the Apple ID text field' do
      expect(described_class.username_field).to eq(text_field)
    end
  end

  describe '#password_field' do
    let(:secure_text_field) { 'secure text field' }
    let(:static_text) { 'static text' }
    let(:sheet) { double }
    let(:sign_in_menu) { double(main_window: double(sheet: sheet)) }

    before(:each) do
      allow(sheet).to receive(:static_text).with(value: 'Password')
        .and_return(static_text)
      allow(sheet).to receive(:secure_text_field)
        .with(title_ui_element: static_text).and_return(secure_text_field)
      allow(described_class).to receive(:sign_in_menu).and_return(sign_in_menu)
    end

    it 'returns the Password text field' do
      expect(described_class.password_field).to eq(secure_text_field)
    end
  end

  describe '#sign_in_menu' do
    let(:signed_in) { nil }
    let(:main_window) { double }
    let(:app_store) { double(main_window: main_window) }
    let(:wait_for) { nil }

    before(:each) do
      allow(main_window).to receive(:search).with(:button, title: 'Sign In')
        .and_return(signed_in)
      allow(described_class).to receive(:app_store).and_return(app_store)
      allow(described_class).to receive(:select_menu_item).and_return(true)
      allow(described_class).to receive(:wait_for)
        .with(:button, main_window, title: 'Sign In')
        .and_return(wait_for)
    end

    context 'Signed in menu not loaded, no timeouts' do
      let(:signed_in) { nil }
      let(:wait_for) { true }

      it 'selects Sign In from the menu' do
        expect(described_class).to receive(:select_menu_item)
          .with(app_store, 'Store', 'Sign In…')
        described_class.sign_in_menu
      end

      it 'waits for the Sign In menu to load' do
        expect(described_class).to receive(:wait_for)
          .with(:button, app_store.main_window, title: 'Sign In')
        described_class.sign_in_menu
      end

      it 'returns the App Store application' do
        expect(described_class.sign_in_menu).to eq(app_store)
      end
    end

    context 'Sign In menu already loaded' do
      let(:signed_in) { true }
      let(:wait_for) { true }

      it 'does not select any menus' do
        expect(described_class).not_to receive(:select_menu_item)
        described_class.sign_in_menu
      end

      it 'does not wait for anything' do
        expect(described_class).not_to receive(:wait_for)
        described_class.sign_in_menu
      end

      it 'returns the App Store application' do
        expect(described_class.sign_in_menu).to eq(app_store)
      end
    end

    context 'timeout waiting for menu to load' do
      let(:wait_for) { nil }

      it 'raises an error' do
        expected = MacAppStoreCookbook::Exceptions::Timeout
        expect { described_class.sign_in_menu }.to raise_error(expected)
      end
    end
  end

  describe '#current_user?' do
    let(:signed_in?) { true }
    let(:user) { 'example@example.com' }
    let(:menu_item) { double(title: "View My Account (#{user})") }
    let(:menu_bar_item) { double }
    let(:app_store) { double }

    before(:each) do
      allow(described_class).to receive(:signed_in?).and_return(signed_in?)
      allow(menu_bar_item).to receive(:menu_item)
        .with(title: /^View My Account /).and_return(menu_item)
      allow(app_store).to receive(:menu_bar_item).with(title: 'Store')
        .and_return(menu_bar_item)
      allow(described_class).to receive(:app_store).and_return(app_store)
    end

    context 'user not signed in' do
      let(:signed_in?) { false }

      it 'returns nil' do
        expect(described_class.current_user?).to eq(nil)
      end
    end

    context 'user signed in' do
      let(:signed_in?) { true }

      it 'returns the username' do
        expect(described_class.current_user?).to eq(user)
      end
    end
  end

  describe '#signed_in?' do
    let(:signed_in?) { false }
    let(:search) { signed_in? ? 'some data' : nil }
    let(:menu_bar_item) { double }
    let(:app_store) { double }

    before(:each) do
      allow(menu_bar_item).to receive(:search)
        .with(:menu_item, title: 'Sign Out').and_return(search)
      allow(app_store).to receive(:menu_bar_item).with(title: 'Store')
        .and_return(menu_bar_item)
      allow(described_class).to receive(:app_store).and_return(app_store)
    end

    context 'user not signed in' do
      let(:signed_in?) { false }

      it 'returns false' do
        expect(described_class.signed_in?).to eq(false)
      end
    end

    context 'user signed in' do
      let(:signed_in?) { true }

      it 'returns true' do
        expect(described_class.signed_in?).to eq(true)
      end
    end
  end

  describe '#quit!' do
    let(:app_store) { double(terminate: true) }
    let(:running?) { false }

    before(:each) do
      allow(described_class).to receive(:app_store).and_return(app_store)
      allow(described_class).to receive(:running?).and_return(running?)
    end

    context 'App Store not running' do
      let(:running?) { false }

      it 'does not try to quit' do
        expect(app_store).not_to receive(:terminate)
        described_class.quit!
      end
    end

    context 'App Store running' do
      let(:running?) { true }

      it 'quits' do
        expect(app_store).to receive(:terminate)
        described_class.quit!
      end
    end
  end

  describe '#app_store' do
    let(:app_store) { double(main_window: 'a main window') }
    let(:wait_for) { nil }

    before(:each) do
      allow(AX::Application).to receive(:new).with('com.apple.appstore')
        .and_return(app_store)
      allow(described_class).to receive(:wait_for)
        .with(:web_area, app_store.main_window).and_return(wait_for)
    end

    context 'normal circumstances, no timeout' do
      let(:wait_for) { true }

      it 'returns an AX::Application object' do
        expect(described_class.app_store).to eq(app_store)
      end

      it 'waits for the Purchases menu to load' do
        expect(described_class).to receive(:wait_for)
          .with(:web_area, app_store.main_window).and_return(true)
        described_class.app_store
      end
    end

    context 'Purchases menu loading timeout' do
      let(:wait_for) { nil }

      it 'raises an exception' do
        expected = MacAppStoreCookbook::Exceptions::Timeout
        expect { described_class.app_store }.to raise_error(expected)
      end
    end
  end

  describe '#running?' do
    let(:running_applications) { [] }

    before(:each) do
      allow(NSRunningApplication)
        .to receive(:runningApplicationsWithBundleIdentifier)
        .with('com.apple.appstore').and_return(running_applications)
    end

    context 'App Store not running' do
      let(:running_applications) { [] }

      it 'returns false' do
        expect(described_class.running?).to eq(false)
      end
    end

    context 'App Store running' do
      let(:running_applications) { %w(some_app) }

      it 'returns true' do
        expect(described_class.running?).to eq(true)
      end
    end
  end

  describe '#wait_for' do
    let(:element) { :element }
    let(:ancestor) { :grandparent }
    let(:search_params) { nil }

    context 'no search params' do
      it 'translates it into a call for AXE wait_for' do
        expect(AX).to receive(:wait_for)
          .with(element, ancestor: ancestor, timeout: 30).and_return(true)
        described_class.wait_for(element, ancestor)
      end
    end

    context 'a description search' do
      let(:search_params) { { description: 'thing' } }

      it 'translates it into a call to AXE wait_for' do
        expect(AX).to receive(:wait_for)
          .with(element, ancestor: ancestor, timeout: 30, description: 'thing')
          .and_return(true)
        described_class.wait_for(element, ancestor, search_params)
      end
    end

    context 'a timeout override' do
      let(:search_params) { { description: 'thing', timeout: 10 } }

      it 'translates it into a call to AXE wait_for' do
        expect(AX).to receive(:wait_for)
          .with(element, ancestor: ancestor, timeout: 10, description: 'thing')
          .and_return(true)
        described_class.wait_for(element, ancestor, search_params)
      end
    end
  end
end
