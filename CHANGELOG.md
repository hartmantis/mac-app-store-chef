# Mac App Store Cookbook CHANGELOG

This file is used to list changes made in each version of the mac-app-store cookbook.

## 4.0.0 (2019-08-02)

- Update all the cookbook boilerplate
- Drop support for Chef < 14
- Convert integration tests from ServerSpec to Inspec
- Remove all references to reattach-to-user-namespace

## 3.1.0 (2017-04-20)

- Update the homebrew cookbook dependency

## 3.0.0 (2017-03-31)

- Update the cookbook dependency pinned versions
- Sign out of Mas before trying to sign in as another user
- Remove all system_user attributes and properties
- Respect a version property in mac_app_store_mas::install
- Raise an error if trying to use Mas before it's installed
- Make Homebrew the default Mas installation method

## 2.1.0 (2016-06-08)

- Add the option of using reattach-to-user-namespace

## 2.0.3 (2016-06-02)

- Shell out as the correct user in helper methods

## 2.0.2 (2016-05-31)

- Quote passwords passed to mas CLI in log_in action

## 2.0.1 (2016-05-24)

- Add a ChefSpec upgrade app matcher

## 2.0.0 (2016-05-23)

- Completely rewrite to use Mas CLI instead of mouse control
- Update to use custom resources (breaking Chef 11 compatibility)

## 1.2.0 (2016-03-25)

- Update build-essential dep to v3.x

## 1.1.1 (2016-02-24)

- Fix issue with bundled apps not getting accessibility rights

## 1.1.0 (2015-08-16)

- Update to Chef 12-style provider mapping (drops compatibility with Chef 11).
- Replace dependency on macosx_accessibility (deprecated) with privacy_services_manager.

## 1.0.1 (2015-08-06)

- Replace references to App Store "Purchases" tab (now named "Purchased").

## 1.0.0 (2015-05-08)

- Pin to a newer (albeit prerelease) version of the AXElements gem that doesn't error out under Yosemite.
- Drop the `mac_app_store_trusted_app` resource--it doesn't belong here. Use the new osx_accessibility cookbook instead.
- Refactor everything out of the compile stage--end the arms race.
- Configure the App Store to open (and quit) on every Chef run--its guard was failing when installing apps inline inside other resources.

## 0.1.0 (2015-04-20)

- Initial release!

## 0.0.1 (2015-01-04)

- Development started
