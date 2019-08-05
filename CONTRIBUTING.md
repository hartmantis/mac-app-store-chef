# Contributing to Cookbooks

Issue submissions and pull requests are welcome.

## Submitting Issues

Not every contribution comes in the form of code. Submitting, confirming, and triaging issues is an important task for any project. New issues for public Socrata cookbooks can be submitted via GitHub.

## Contributing Process

Contributions can be submitted via GitHub pull requests. See [this article](https://help.github.com/articles/about-pull-requests/) if you're not familiar with GitHub Pull Requests. In brief:

1. Fork the project's repo in GitHub.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Add code and tests for the new feature.
4. Ensure all tests pass (`chef exec delivery local all` + `chef exec kitchen test`).
5. Bump the version string in `metadata.rb` in accordance with [semver](http://semver.org).
6. Add a brief description of the change to `CHANGELOG.md`.
7. Commit your changes (`git commit -am 'Add some feature'`).
8. Push the branch to GitHub (`git push origin my-new-feature`).
9. Create a new pull request.
10. Ensure the build process for the pull request succeeds.
11. Enjoy life until the change can be reviewed by a cookbook maintainer.
