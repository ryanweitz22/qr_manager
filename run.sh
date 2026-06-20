#!/bin/bash
echo "Which Ruby version would you like to run locally?"
echo "Type 3.3.4 or 4.0.2 and press Enter:"
read RUBY_VERSION

if [ "$RUBY_VERSION" != "3.3.4" ] && [ "$RUBY_VERSION" != "4.0.2" ]; then
  echo "Invalid version. Please enter exactly 3.3.4 or 4.0.2."
  exit 1
fi

export RUBY_VERSION
export RAILS_MASTER_KEY=$(cat config/master.key)

echo "Building and starting QR Manager with Ruby $RUBY_VERSION..."
docker compose up --build
