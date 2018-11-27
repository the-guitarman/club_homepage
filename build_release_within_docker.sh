#!/usr/bin/env bash

# This script is used in build_release.sh

set -e

BUILD_DIR="/opt/build"

cd $BUILD_DIR

APP_NAME="$(grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')"
APP_VSN="$(grep 'version:' mix.exs | cut -d '"' -f2)"
#APP_VSN="$(cat mix.exs| grep version: | head -n1 | awk -F: '{print $2}' | sed 's/[\",]//g' | tr -d '[[:space:]]')"
echo $APP_VSN > .version

function clean_dependency {
    # App dependency stuff
    cd $BUILD_DIR/deps/bcrypt_elixir
    #cd $BUILD_DIR/deps/argon2_elixir
    echo $(pwd) && make clean && make
}

clean_dependency

cd $BUILD_DIR/assets && echo $(pwd) && npm install && ./node_modules/brunch/bin/brunch build --production && cd ..

cd $BUILD_DIR
echo $(pwd)

mkdir -p $BUILD_DIR/rel/artifacts

# Install updated versions of hex/rebar
mix local.rebar --force
mix local.hex --if-missing --force

export MIX_ENV=prod
echo $MIX_ENV

# Fetch deps and compile
mix deps.get

# Run an explicit clean to remove any build artifacts from the host
mix do clean, compile --force

# Removes old versions of static assets.
mix phx.digest.clean

# Digests and compresses static files
mix phx.digest

# Build the release
mix release --env=prod

# Copy tarball to output
cp "_build/prod/rel/$APP_NAME/releases/$APP_VSN/$APP_NAME.tar.gz" rel/artifacts/"$APP_NAME-$APP_VSN.tar.gz"

clean_dependency

exit 0
