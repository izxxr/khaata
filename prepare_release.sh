#!/bin/bash

rm -rf .releases/*
mkdir -p .releases

fmt_ver=$(sed 's/\./\-/g' <<< "$1")
rl_date=$(date +%Y-%m-%d)

src_dir="build/app/outputs/flutter-apk"

for abi in x86_64 arm64-v8a armeabi-v7a; do
    apk="app-${abi}-release.apk"
    sha1="${apk}.sha1"

    mv "$src_dir/$apk" \
       ".releases/khaata-v${fmt_ver}-release-${rl_date}-${abi}.apk"

    mv "$src_dir/$sha1" \
       ".releases/khaata-v${fmt_ver}-release-${rl_date}-${abi}.apk.sha1"
done