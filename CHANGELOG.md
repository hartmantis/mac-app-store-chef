Mac App Store Cookbook CHANGELOG
================================

v?.?.? (????-??-??)
-------------------

v1.1.0 (2015-08-16)
-------------------
- Update to Chef 12-style provider mapping (drops compatibility with Chef 11).
- Replace dependency on macosx_accessibility (deprecated) with
  privacy_services_manager.

v1.0.1 (2015-08-06)
-------------------
- Replace references to App Store "Purchases" tab (now named "Purchased").

v1.0.0 (2015-05-08)
-------------------
- Pin to a newer (albeit prerelease) version of the AXElements gem that doesn't
  error out under Yosemite.
- Drop the `mac_app_store_trusted_app` resource--it doesn't belong here. Use
  the new osx_accessibility cookbook instead.
- Refactor everything out of the compile stage--end the arms race.
- Configure the App Store to open (and quit) on every Chef run--its guard
  was failing when installing apps inline inside other resources.

v0.1.0 (2015-04-20)
-------------------
- Initial release!

v0.0.1 (2015-01-04)
-------------------
- Development started
