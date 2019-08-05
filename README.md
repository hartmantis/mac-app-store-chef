# Mac App Store Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/mac-app-store.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/RoboticCheese/mac-app-store-chef.svg)][travis]

[cookbook]: https://supermarket.getchef.com/cookbooks/mac-app-store
[travis]: https://travis-ci.org/RoboticCheese/mac-app-store-chef

A Chef cookbook for installation of Mac App Store apps via the [Mas](https://github.com/mas-cli/mas) CLI tool.

## Requirements

Mas requires OS X 10.10+. As of v2.0, this cookbook requires Chef 12.5+ (or Chef 12.x and the [compat_resource](https://supermarket.chef.io/cookbooks/compat_resource) cookbook.

A user must be logged into OS X for Mas to operate properly.

## Usage

Apps can be installed by using the included custom resources in recipes of your own, or with the predefined recipe and set of attributes.

## Recipes

***default***

Installs the Mas CLI tool and an attribute-derived set of App Store apps.

## Attributes

***default***

```ruby
default['mac_app_store']['username'] = nil
default['mac_app_store']['password'] = nil
```

Set these two attributes with the Apple ID user and password you wish to log
into the App Store as.

```ruby
default['mac_app_store']['apps'] = {}
```

Set apps as keys+values under this space, where the key is the full app name
and value is true to install it or false to not. For example:

```ruby
default['mac_app_store']['apps']['Growl'] = true
```

Mas can be installed via Homebrew (`:homebrew`, the default) or GitHub download (`:direct`).

```ruby
default['mac_app_store']['mas']['source'] = nil
```

If desired, a specific version of Mas can be installed rather than the latest:

```ruby
default['mac_app_store']['mas']['version'] = nil
```

In certain circumstances-e.g. Chef running as root-it may be necessary to run Mas via the `reattach-to-user-namespace` utility:

```ruby
default['mac_app_store']['mas']['use_rtun'] = nil
```

## Resources

***mac_app_store_mas***

A custom resource to manage installation of the Mas CLI tool for interacting with the App Store.

Syntax:

```ruby
mac_app_store_mas 'default' do
  source :direct
  version: '1.2.3'
  username 'example@example.com'
  password 'abc123'
  use_rtun false
  action %i[install sign_in]
end
```

Properties:

| Property    | Default               | Description                                    |
|-------------|-----------------------|------------------------------------------------|
| source      | `:homebrew`           | Install from `:homebrew` or GitHub (`:direct`) |
| version     | `nil`                 | The version of Mas to install                  |
| username    | `nil`                 | An Apple ID username                           |
| password    | `nil`                 | An Apple ID password                           |
| use_rtun    | `false`               | Use RtUN when shelling out to Mas              |
| action      | `%i[install sign_in]` | Action(s) to perform                           |

Actions:

| Action          | Description                                 |
|-----------------|---------------------------------------------|
| `:install`      | Default; install the Mas CLI                |
| `:upgrade`      | Upgrade Mas, if available                   |
| `:remove`       | Uninstall Mas                               |
| `:sign_in`      | Use Mas to sign into the App Store          |
| `:sign_out`     | Sign out of the App Store                   |
| `:upgrade_apps` | Install any upgrades for apps on the system |

***mac_app_store_app***

Used to install a single App Store app via Mas. Requires that an Apple ID be signed into.

Syntax:

```ruby
mac_app_store_app 'Some App' do
  app_name 'Some App'
  use_rtun false
  action :install
end
```

Properties:

| Property    | Default        | Description                                |
|-------------|----------------|--------------------------------------------|
| app_name    | resource name  | App name if it doesn't match resource name |
| use_rtun    | `false`        | Use RtUN when shelling out to Mas          |
| action      | `:install`     | Action(s) to perform                       |

Actions:

| Action     | Description                     |
|------------|---------------------------------|
| `:install` | Default; installs the given app |
| `:upgrade` | Upgrade or install the app      |

## Maintainers

- Jonathan Hartman <j@hartman.io>
