# encoding: utf-8
# frozen_string_literal: true

name 'mac-app-store'
maintainer 'Jonathan Hartman'
maintainer_email 'j@p4nt5.com'
license 'Apache-2.0'
description 'Automates installation of Mac App Store apps'
long_description 'Automates installation of Mac App Store apps'
version '3.1.1'
chef_version '>= 12.1'

source_url 'https://github.com/roboticcheese/mac-app-store-chef'
issues_url 'https://github.com/roboticcheese/mac-app-store-chef/issues'

depends 'reattach-to-user-namespace', '~> 0.2'

supports 'mac_os_x'
