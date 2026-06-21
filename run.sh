#!/bin/bash
echo "Which Ruby version would you like to run locally?"
echo "Type a Ruby version (e.g. 3.3.4 or 4.0.2) and press Enter:"
read RUBY_VERSION

if [ -z "$RUBY_VERSION" ]; then
  echo "No version entered. Exiting."
  exit 1
fi

echo "Updating Gemfile to match Ruby $RUBY_VERSION..."
sed -i "s/^ruby \".*\"/ruby \"$RUBY_VERSION\"/" Gemfile

export RUBY_VERSION
export RAILS_MASTER_KEY=$(cat config/master.key)

echo "Building and starting QR Manager with Ruby $RUBY_VERSION..."
docker compose up --build
