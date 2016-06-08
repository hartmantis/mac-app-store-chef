Mac App Store Cookbook
======================
[![Cookbook Version](https://img.shields.io/cookbook/v/mac-app-store.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/RoboticCheese/mac-app-store-chef.svg)][travis]
[![Code Climate](https://img.shields.io/codeclimate/github/RoboticCheese/mac-app-store-chef.svg)][codeclimate]
[![Coverage Status](https://img.shields.io/coveralls/RoboticCheese/mac-app-store-chef.svg)][coveralls]

[cookbook]: https://supermarket.getchef.com/cookbooks/mac-app-store
[travis]: https://travis-ci.org/RoboticCheese/mac-app-store-chef
[codeclimate]: https://codeclimate.com/github/RoboticCheese/mac-app-store-chef
[coveralls]: https://coveralls.io/r/RoboticCheese/mac-app-store-chef

A Chef cookbook for installation of Mac App Store apps via the
[Mas](https://github.com/argon/mas) CLI tool.

Requirements
============

Mas requires OS X 10.10+. As of v2.0, this cookbook requires Chef 12.5+ (or
Chef 12.x and the
[compat_resource](https://supermarket.chef.io/cookbooks/compat_resource)
cookbook.

A user must be logged into OS X for Mas to operate properly.

Usage
=====

Apps can be installed by using the included custom resources in recipes of your
own, or with the predefined recipe and set of attributes.

Recipes
=======

***default***

Installs the Mas CLI tool and an attribute-derived set of App Store apps.

Attributes
==========

***default***

    default['mac_app_store']['username'] = nil
    default['mac_app_store']['password'] = nil

Set these two attributes with the Apple ID user and password you wish to log
into the App Store as.

    default['mac_app_store']['apps'] = {}

Set apps as keys+values under this space, where the key is the full app name
and value is true to install it or false to not. For example:

    default['mac_app_store']['apps']['Growl'] = true

Mas can be installed via GitHub download (`:direct`, the default) or from
`:homebrew`.

    default['mac_app_store']['mas']['source'] = nil

If desired, a specific version of Mas can be installed rather than the latest:

    default['mac_app_store']['mas']['version'] = nil

By default, Mas will always be run as the current system user. That can be
overridden:

    default['mac_app_store']['mas']['system_user'] = nil

In certain circumstances-e.g. Chef running as root-it may be necessary to run
Mas via the `reattach-to-user-namespace` utility:

    default['mac_app_store']['mas']['use_rtun'] = nil

Resources
=========

***mac_app_store_mas***

A custom resource to manage installation of the Mas CLI tool for interacting
with the App Store.

Syntax:

    mac_app_store_mas 'default' do
      source :direct
      version: '1.2.3'
      username 'example@example.com'
      password 'abc123'
      system_user 'vagrant'
      use_rtun false
      action %i(install sign_in)
    end

Actions:

| Action          | Description                                 |
|-----------------|---------------------------------------------|
| `:install`      | Default; install the Mas CLI                |
| `:upgrade`      | Upgrade Mas, if available                   |
| `:remove`       | Uninstall Mas                               |
| `:sign_in`      | Use Mas to sign into the App Store          |
| `:sign_out`     | Sign out of the App Store                   |
| `:upgrade_apps` | Install any upgrades for apps on the system |

Properties:

| Property    | Default               | Description                                    |
|-------------|-----------------------|------------------------------------------------|
| source      | `:direct`             | Install from GitHub (`:direct`) or `:homebrew` |
| version     | `nil`                 | The version of Mas to install                  |
| username    | `nil`                 | An Apple ID username                           |
| password    | `nil`                 | An Apple ID password                           |
| system_user | `Etc.getlogin`        | The user to execute Mas commands as            |
| use_rtun    | `false`               | Use RtUN when shelling out to Mas              |
| action      | `%i(install sign_in)` | Action(s) to perform                           |

***mac_app_store_app***

Used to install a single App Store app via Mas. Requires that an Apple ID be
signed into.

Syntax:

    mac_app_store_app 'Some App' do
      app_name 'Some App'
      system_user 'vagrant'
      use_rtun false
      action :install
    end

Actions:

| Action     | Description                     |
|------------|---------------------------------|
| `:install` | Default; installs the given app |
| `:upgrade` | Upgrade or install the app      |

Properties:

| Property    | Default        | Description                                |
|-------------|----------------|--------------------------------------------|
| app_name    | resource name  | App name if it doesn't match resource name |
| system_user | `Etc.getlogin` | The user to execute Mas commands as        |
| use_rtun    | `false`        | Use RtUN when shelling out to Mas          |
| action      | `:install`     | Action(s) to perform                       |

Contributing
============

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests for the new feature; ensure they pass (`bundle exec rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request
7. Watch the pull request and ensure the build passes

License & Authors
=================
- Author: Jonathan Hartman <j@p4nt5.com>

Copyright 2015-2016, Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
