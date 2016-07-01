#!/bin/bash

set -e
#set -v

THIS_SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# ---------------------
# Install SDK
# ---------------------
INSTALLED_SDK=$(brew ls --versions pebble-sdk)
if [[ $INSTALLED_SDK ]]; then
    echo "$INSTALLED_SDK already installed => skipping 'brew install'"
else
    # iterate over environment variables, e.g. pebbe_without_emulator and construct SDK_OPTIONS
    SDK_OPTIONS=""
    for option in emulator freetype node; do
        option_arg="sdk_without_$option"
        if [ "${!option_arg}" == "yes" ]; then
            SDK_OPTIONS="$SDK_OPTIONS--without-$option "
        fi
    done

    # make brew aware of pebble-qemu
    brew tap pebble/pebble-sdk

    echo "Installing pebbke-sdk with options: $SDK_OPTIONS"
    # TODO: replace local homebrew recipe with public one once the PR landed
    #   https://github.com/pebble/homebrew-pebble-sdk/pull/46
    cmd="brew install $THIS_SCRIPTDIR/pebble-sdk.rb $SDK_OPTIONS"
    eval $cmd

    if [ $sdk_analytics_enabled == "yes" ]; then
        echo "SDK analytics enabled"
        analytics_file="ENABLE_ANALYTICS"
    else
        echo "SDK analytics disabled"
        analytics_file="NO_TRACKING"
    fi
    touch "$HOME/Library/Application Support/Pebble SDK/$analytics_file"

    # TODO: download specific SDK version
fi

# ---------------------
# Build Project
# ---------------------
if [[ $project_path ]]; then
  echo "Pebble project configured at $project_path"
  pushd "$project_path"
  pebble build
  popd
else
  echo "No path for Pebble project specified => skipping build"
fi