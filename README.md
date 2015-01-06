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
by attempting to automating GUI window switches and button clicks. It remains to
be seen what might result from, for example, a user performing certain mouse
actions at the same time Chef is trying to do the same.

To allow it to take over mouse navigation, the app running Chef (e.g. Terminal
or iTerm) needs to be allowed in System Preferences under Security & Privacy ->
Privacy -> Accessibility.

To use this cookbook, you must be signed into the App Store. If you open the App
Store and click the "Purchases" header button, you should see a list of apps.

Nothing in this cookbook will attempt to purchase an app for you--it can only
install ones that are already in your purchase history.

Usage
=====

A new resource is defined as well as an attribute-driven default recipe, either
of which can be used.

Recipes
=======

***default***

Installs any apps in an attribute list.

Attributes
==========

***default***

    default['mac_app_store']['apps'] = nil

A set of apps to install is empty by default and can be overridden with a hash
of app names (as displayed in the App Store) and app IDs (as displayed in the
output of `pkgutil --pkgs`.

    default['mac_app_store']['apps']['Tweetbot for Twitter'] = 'com.tapbots.TweetbotMac'

Resources
=========

***mac_app_store_app***

Used to install a single app from the App Store.

Syntax:

    mac_app_store_app 'Some App' do
        app_id 'com.example.someapp'
        action :install
    end

Actions:

| Action     | Description                     |
|------------|---------------------------------|
| `:install` | Default; installs the given app |

Attributes:

| Attribute  | Default        | Description                                  |
|------------|----------------|----------------------------------------------|
| app\_id    | `nil`          | Required; the app ID as displayed by pkgutil |
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
