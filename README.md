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

Usage
=====

A new resource is defined as well as an attribute-driven default recipe, either
of which can be used.

Caveats
=======

Your Chef run may be slow; try to be patient. This is due to all the page loads
that have to be waited on while navigating around the App Store.

_DO NOT_ switch between windows in OS X while Chef is running--it is important
for the UI interaction that Chef have full control. If you Cmd+Tab during a run,
unexpected and probably undesirable behavior will occur.

For an application (e.g. the Terminal app Chef might run in) to control mouse
and keyboard interaction, it needs access to OS X's Accessibility API. This
cookbook will attempt attempt to configure that, but any errors in that attempt
will result in the Chef run exiting with an error and a popup window prompting
you to visit your system's accessibility settings.

The Accessibility API, and the App Store in particular, are suceptible to
assorted race conditions. Attempts have been made to account for these, but
any errors mentioning timeouts or `AXAPI has been disabled` can be submitted,
along with their stack traces, as GitHub
[issues](https://github.com/RoboticCheese/mac-app-store-chef/issues).

Recipes
=======

***default***

* Installs the OS X command line tools (via the `build-essential` cookbook)
* Opens the Mac App Store
* Signs into the App Store with a given Apple ID
* Installs each of an attribute-derived list of apps

Attributes
==========

***default***

An attribute is supplied to represent a set of apps to install:

    default['mac_app_store']['apps'] = nil

It can be overridden with an array of app names (as displayed in the App Store):

    default['mac_app_store']['apps'] = ['Tweetbot for Twitter']

By default, the main recipe assumes an Apple ID is already signed into the App
Store, but a set of credentials can be provided:

    default['mac_app_store']['username'] = nil
    default['mac_app_store']['password'] = nil

Resources
=========

***mac_app_store***

A singleton resource, there can be only one. Used to start and configure the
App Store application itself.

Syntax:

    mac_app_store 'default' do
      username 'example@example.com'
      password 'abc123'
      action :open
    end

Actions:

| Action     | Description                     |
|------------|---------------------------------|
| `:open`    | Default; starts the App Store   |
| `:quit`    | Quits the App Store             |

Attributes:

| Attribute  | Default        | Description                                  |
|------------|----------------|----------------------------------------------|
| username   | `nil`          | An Apple ID username                         |
| password   | `nil`          | An Apple ID password                         |
| action     | `:open`        | Action(s) to perform                         |

***mac_app_store_app***

Used to install a single app from the App Store. Requires that the App Store
be running and an Apple ID signed into.

Syntax:

    mac_app_store_app 'Some App' do
      timeout 1200
      bundle_id 'com.example.someapp'
      action :install
    end

Actions:

| Action     | Description                     |
|------------|---------------------------------|
| `:install` | Default; installs the given app |

Attributes:

| Attribute | Default    | Description                                  |
|-----------|------------|----------------------------------------------|
| timeout   | `600`      | Time to wait on a download + install         |
| bundle_id | `nil`      | Optionally specify the app ID (from pkgutil) |
| action    | `:install` | Action(s) to perform                         |

Providers
=========

***Chef::Provider::MacAppStore***

Provider for interactions with the App Store itself.

***Chef::Provider::MacAppStoreApp***

All the logic for app installs.

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

Copyright 2015 Jonathan Hartman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
