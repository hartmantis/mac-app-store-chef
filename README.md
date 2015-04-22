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

Any reference to an application name means the name displayed in the App Store
(e.g. even though the app is named "Tweetbot" its App Store entry calls it
"Tweetbot for Twitter"). Any reference to the bundle or package ID means the
package's ID as shown in the output of the `pkgutil` command.

Some example app names and their corresponding bundle IDs, as of 2015-04-18
(some of them seem to change over time to correspond to their versions):

| App Name                                       | Bundle ID                         |
|------------------------------------------------|-----------------------------------|
| 1Password - Password Manager and Secure Wallet | com.agilebits.onepassword-osx     |
| Airmail                                        | it.bloop.airmail                  |
| Dash - API Docs & Snippets                     | com.kapeli.dash                   |
| Divvy - Window Manager                         | com.mizage.Divvy                  |
| Evernote                                       | com.evernote.Evernote             |
| Fantastical - Calendar and Reminders           | com.flexibits.fantastical         |
| Fantastical 2 - Calendar and Reminders         | com.flexibits.fantastical2.mac    |
| FaxFresh                                       | com.purplecover.faxfresh          |
| GarageBand 6.0.5                               | com.apple.pkg.GarageBand_AppStore |
| GIF Brewery                                    | com.helloresolven.CineGIF         |
| Growl                                          | com.Growl.GrowlHelperApp          |
| iBooks Author                                  | com.apple.pkg.iBooksAuthor        |
| iMovie                                         | com.apple.pkg.iMovie_AppStore     |
| iPhoto                                         | com.apple.pkg.iPhoto_AppStore     |
| Keynote                                        | com.apple.pkg.Keynote6            |
| Kindle                                         | com.amazon.Kindle                 |
| Lock Me Now                                    | com.bymaster.lockmenow            |
| Mail Pilot                                     | co.mindsense.MailPilotMac         |
| Markdown Pro                                   | com.radsense.markdown             |
| Marked                                         | com.brettterpstra.marky           |
| Microsoft OneNote                              | com.microsoft.onenote.mac         |
| Microsoft Remote Desktop                       | com.microsoft.rdc.mac             |
| MPlayerX                                       | org.niltsh.MPlayerX               |
| Numbers                                        | com.apple.pkg.Numbers3            |
| OceanBar                                       | com.stylemac.OceanBar             |
| Osfoora for Twitter                            | osfoora.osfooramac                |
| Pages                                          | com.apple.pkg.Pages5              |
| Reeder                                         | com.reederapp.mac                 |
| Slack                                          | com.tinyspeck.slackmacgap         |
| SourceTree (Git/Hg)                            | com.torusknot.SourceTree          |
| Sunrise Calendar                               | m.sunrise.mac                     |
| Textual                                        | com.codeux.irc.textual            |
| The 7th Guest                                  | com.trilobytegames.the7thguestosx |
| Trillian                                       | com.ceruleanstudios.trillian.osx  |
| Tweetbot for Twitter                           | com.tapbots.TweetbotMac           |
| Twitter                                        | com.twitter.twitter-mac           |
| Visual JSON                                    | org.3rddev.VisualJSON             |
| White Noise Lite                               | com.tmsoft.mac.WhiteNoiseLite     |
| WiFi Explorer                                  | wifiexplorer                      |
| Xcode                                          | com.apple.pkg.Xcode               |

Known Limitations
-----------------

* Your Chef run may be slow, especially if bundle IDs aren't provided for the
apps being installed. This is due to all the page loads that have to be waited
on while navigating the App Store.
* A successful run requires Chef to have control over OS X's UI--moving your
mouse or pressing Cmd+Tab during a run may result in undesirable behavior.
* The UI actions performed by this cookbook require a running window server--a
user must be logged into OS X.
* OS X uses a permission system where individual apps are granted access to
its Accessibility API. This cookbook will make a best effort to authorize the
app running Chef, but any errors will result in a failed Chef run and a GUI
warning popup asking for permission.
* The Accessibility API, and the App Store in particular, are suceptible to
assorted race conditions. Attempts have been made to catch most of these, but
any errors and stack traces can be reported on the
[issues page](https://github.com/RoboticCheese/mac-app-store-chef/issues).

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

Optionally, the bundle IDs for the apps (as displayed in pkgutil) can also be
provided to speed up the Chef run:

    default['mac_app_store']['apps'] = [
      { name: 'Tweetbot for Twitter', bundle_id: 'com.tapbots.TweetbotMac' }
    ]

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
      app_name 'Some App'
      timeout 1200
      bundle_id 'com.example.someapp'
      action :install
    end

Actions:

| Action     | Description                     |
|------------|---------------------------------|
| `:install` | Default; installs the given app |

Attributes:

| Attribute | Default       | Description                                  |
|-----------|---------------|----------------------------------------------|
| app_name  | resource name | App name if it doesn't match resource name   |
| timeout   | `600`         | Time to wait on a download + install         |
| bundle_id | `nil`         | Optionally specify the app ID (from pkgutil) |
| action    | `:install`    | Action(s) to perform                         |

***mac_app_store_trusted_app***

Modifies the SQLite DB containing OS X's Accessibility API settings to grant
access to new apps (i.e. the one running Chef). New apps will either take the
form of a bundle ID (`com.example.someapp`) or path (`/usr/bin/someapp`).

Syntax:

    mac_app_store_trusted_app 'com.example.someapp' do
      compile_time true
      action :create
    end

Actions:

| Action    | Description                      |
|-----------|----------------------------------|
| `:create` | Default; grant access to the app |

Attributes:

| Attribute    | Default   | Description                          |
|--------------|-----------|--------------------------------------|
| compile_time | `false`   | Create rule during the compile stage |
| action       | `:create` | Action(s) to perform                 |

Providers
=========

***Chef::Provider::MacAppStore***

Provider for interactions with the App Store itself.

***Chef::Provider::MacAppStoreApp***

All the logic for app installs.

***Chef::Provider::MacAppStoreTrustedApp***

Provider for authoring new apps to use the Accessibility API.

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
