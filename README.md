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

A Chef cookbook for installation of Mac App Store apps.

Requirements
============

Obviously, OS X is required. Some tempered expectations are as well--there is
no documented public API for installing App Store apps, so this cookbook works
by automating GUI window switches and button clicks.

Nothing in this cookbook will attempt to purchase an app for you--it can only
install ones that are already in your purchase history.

As of v2.0, this cookbook requires Chef 12.5 or higher (or Chef 12.x and the
[compat_resource](https://supermarket.chef.io/cookbooks/compat_resource)
cookbook.

Usage
=====

Apps can be installed by using the included custom resources in recipes of your
own, or with the predefined recipe and set of attributes.

Known Limitations
-----------------

* A user must be logged into OS X for Mas (the underlying utility we use to
  manage installed apps) can function.

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

    default[['mac_app_store']['apps']['Growl'] = true

Resources
=========

***mac_app_store_mas***

A custom resource to manage installation of the Mas CLI tool for interacting
with the App Store.

Syntax:

    mac_app_store_mas 'default' do
      source :direct
      username 'example@example.com'
      password 'abc123'
      version: '1.2.3'
      action %i(install sign_in)
    end

Actions:

| Action      | Description                        |
|-------------|------------------------------------|
| `:install`  | Default; install the Mas CLI       |
| `:upgrade`  | Upgrade Mas, if available          |
| `:remove`   | Uninstall Mas                      |
| `:sign_in`  | Use Mas to sign into the App Store |
| `:sign_out` | Sign out of the App Store          |

Properties:

| Property | Default               | Description                                    |
|----------|-----------------------|------------------------------------------------|
| source   | `:direct`             | Install from GitHub (`:direct`) or `:homebrew` |
| username | `nil`                 | An Apple ID username                           |
| password | `nil`                 | An Apple ID password                           |
| version  | `nil`                 | The version of Mas to install                  |
| action   | `%i(install sign_in)` | Action(s) to perform                           |

***mac_app_store_app***

Used to install a single App Store app via Mas. Requires that an Apple ID be
signed into.

Syntax:

    mac_app_store_app 'Some App' do
      app_name 'Some App'
      action :install
    end

Actions:

| Action     | Description                     |
|------------|---------------------------------|
| `:install` | Default; installs the given app |

Properties:

| Property | Default       | Description                                |
|----------|---------------|--------------------------------------------|
| app_name | resource name | App name if it doesn't match resource name |
| action   | `:install`    | Action(s) to perform                       |

Contributing
============

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Add tests for the new feature; ensure they pass (`rake`)
4. Commit your changes (`git commit -am 'Add some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create a new Pull Request

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
