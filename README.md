# Mac App Store Cookbook

[![Cookbook Version](https://img.shields.io/cookbook/v/mac-app-store.svg)][cookbook]
[![Build Status](https://img.shields.io/travis/RoboticCheese/mac-app-store-chef.svg)][travis]

[cookbook]: https://supermarket.getchef.com/cookbooks/mac-app-store
[travis]: https://travis-ci.org/RoboticCheese/mac-app-store-chef

A Chef cookbook for installation of Mac App Store apps via the [Mas](https://github.com/mas-cli/mas) CLI tool.

## Requirements

This cookbook assumes a running macOS node, with Homebrew installed, that is supported for use with the [Mas](https://github.com/mas-cli/mas) utility.

A user must be signed into the App Store for Mas to be able to install apps.

## Usage

Use the included custom resources to install the Mas utility and Mac App Store apps.

## Resources

***mac_app_store_mas***

A custom resource to manage installation of the Mas CLI tool for interacting with the App Store.

Syntax:

```ruby
mac_app_store_mas 'default' do
  version: '1.2.3'
  username 'example@example.com'
  password 'abc123'
  action %i[install sign_in]
end
```

Properties:

| Property    | Default               | Description                                    |
|-------------|-----------------------|------------------------------------------------|
| version     | `nil`                 | The version of Mas to install                  |
| username    | `nil`                 | An Apple ID username                           |
| password    | `nil`                 | An Apple ID password                           |
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
  action :install
end
```

Properties:

| Property    | Default        | Description                                |
|-------------|----------------|--------------------------------------------|
| app_name    | resource name  | App name if it doesn't match resource name |
| action      | `:install`     | Action(s) to perform                       |

Actions:

| Action     | Description                     |
|------------|---------------------------------|
| `:install` | Default; installs the given app |
| `:upgrade` | Upgrade or install the app      |

## Maintainers

- Jonathan Hartman <j@hartman.io>
