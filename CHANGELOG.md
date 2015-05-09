Mac App Store Cookbook CHANGELOG
================================

v?.?.? (????-??-??)
-------------------

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
