# Encoding: UTF-8
#
# rubocop:disable SingleSpaceBeforeFirstArg
name             'mac-app-store'
maintainer       'Jonathan Hartman'
maintainer_email 'j@p4nt5.com'
license          'Apache v2.0'
description      'Automates installation of Mac App Store apps'
long_description 'Automates installation of Mac App Store apps'
version          '1.0.2'

depends          'build-essential', '~> 2.1'
depends          'now', '~> 0.3'
depends          'privacy_services_manager', '~> 1.0'

supports         'mac_os_x'
# rubocop:enable SingleSpaceBeforeFirstArg
