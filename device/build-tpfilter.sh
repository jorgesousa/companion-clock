#!/bin/sh
# Builds device/tpfilter (armv7, Android 21+) with the Android NDK installed by Android Studio.
set -e
cd "$(dirname "$0")"
NDK=${NDK:-$(ls -d "$HOME"/Library/Android/sdk/ndk/* | tail -1)}
CC="$NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin/armv7a-linux-androideabi21-clang"
"$CC" -O2 -Wall -s -o tpfilter tpfilter.c
echo "built device/tpfilter"
