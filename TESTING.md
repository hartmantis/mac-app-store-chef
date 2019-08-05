# Cookbook Testing

This document describes the process for testing a cookbook.

## Prerequisites

A working Chef Workstation or Chef Development Kit installation is required.

Chef Workstation can be installed via...

- Direct [download](https://downloads.chef.io/chef-workstation/)
- Homebrew (`brew cask install chef-workstation`)
- Chocolatey (`choco install chef-workstation`)
- APT/YUM/shell script (documented [here](https://docs.chef.io/packages.html))
- The [chef-ingredient cookbook](https://supermarket.chef.io/cookbooks/chef-ingredient)

The Chef-DK can be installed via...

- Direct [download](https://downloads.chef.io/chef-dk/)
- Homebrew (`brew cask install chefdk`)
- Chocolatey (`choco install chefdk`)
- APT/YUM/shell script (documented [here](https://docs.chef.io/packages.html))
- The [chefdk cookbook](https://supermarket.chef.io/cookbooks/chefdk)
- The [chef-dk cookbook](https://supermarket.chef.io/cookbooks/chef-dk)
- The [chef-ingredient cookbook](https://supermarket.chef.io/cookbooks/chef-ingredient)

The integration tests assume access to a macOS virtual machine.

## Installing Dependencies

Install additional gem dependencies into Chef's Ruby environment:

```shell
> chef exec bundle install
```

## Local Delivery

Syntax, style, and unit tests are handled by the Delivery CLI tool running in the local delivery mode.

***Lint Phase***

The lint phase uses [RuboCop](https://github.com/bbatsov/rubocop) to examine the cookbook's Ruby code for style violations. To run only the lint phase:

```shell
> chef exec delivery local lint
```

***Syntax Phase***

The syntax phase uses [FoodCritic](http://www.foodcritic.io) to catch any Chef-specific cookbook issues. To run only the syntax phase:

```shell
> chef exec delivery local syntax
```

***Unit Phase***

The unit phase uses [ChefSpec](https://github.com/chefspec/chefspec) to run any unit tests present in the `spec/` directory. To run only the unit phase:

```shell
> chef exec delivery local unit
```

***All Phases***

To run all the above phases in sequence:

```shell
> chef exec delivery local all
```

## Test Kitchen

Integration testing is handled outside of Delivery by [Test Kitchen](https://kitchen.ci). To run all available integration tests on all plaforms and suites:

```shell
> chef exec kitchen test
```
