#!/usr/bin/env bash
set -euo pipefail

echo "==> RSpec"
bundle exec rspec

echo "==> RuboCop"
bin/rubocop

echo "==> Brakeman"
bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error

echo "==> Bundler Audit"
bin/bundler-audit check --update

echo "All checks passed."
