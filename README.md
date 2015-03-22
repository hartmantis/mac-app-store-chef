Mac App Store Cookbook
======================
[![Cookbook Version](http://img.shields.io/cookbook/v/mac-app-store.svg)][cookbook]
[![Build Status](http://img.shields.io/travis/RoboticCheese/mac-app-store-chef.svg)][travis]
[![Code Climate](http://img.shields.io/codeclimate/github/RoboticCheese/mac-app-store-chef.svg)][codeclimate]
[![Coverage Status](http://img.shields.io/coveralls/RoboticCheese/mac-app-store-chef.svg)][coveralls]

[cookbook]: https://supermarket.getchef.com/cookbooks/mac-app-store
[travis]: http://travis-ci.org/RoboticCheese/mac-app-store-chef
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

_DO NOT_ switch between windows in OS X while Chef is running--it is important
for the UI interaction that Chef have full control. If you Cmd+Tab during a run,
unexpected and probably undesirable behavior will occur.

For an application (e.g. the Terminal instance you might run Chef in) to
control mouse and keyboard interaction, it must be given access in OS X's
Accessibility settings. This cookbook _WILL_ modify those settings when run.

The default recipe also installs the OS X dev tools required via the
`build-essential` cookbook. If you are calling the resource directly, you'll
need to ensure XCode is installed separately.

Recipes
=======

***default***

Installs any apps in an attribute list.

Attributes
==========

***default***

An attribute is supplied to represent a set of apps to install:

    default['mac_app_store']['apps'] = nil

It can be overridden with an array of app names (as displayed in the App Store):

    default['mac_app_store']['apps'] = %w(Tweetbot for Twitter)

By default, the main recipe assumes an Apple ID is already signed into the App
Store, but a set of credentials can be provided:

    default['mac_app_store']['username'] = nil
    default['mac_app_store']['password'] = nil

Resources
=========

***mac_app_store_app***

Used to install a single app from the App Store.

Syntax:

    mac_app_store_app 'Some App' do
        timeout 1200
        username 'example@example.com'
        password 'abc123'
        action :install
    end

Actions:

| Action     | Description                     |
|------------|---------------------------------|
| `:install` | Default; installs the given app |

Attributes:

| Attribute  | Default        | Description                                  |
|------------|----------------|----------------------------------------------|
| timeout    | `600`          | Time to wait on a download + install         |
| username   | `nil`          | An Apple ID username                         |
| password   | `nil`          | An Apple ID password                         |
| action     | `:install`     | Action(s) to perform                         |

Providers
=========

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
