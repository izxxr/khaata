rm -rf releases/*

cp build/app/outputs/flutter-apk/app-release.apk .releases
cp build/app/outputs/flutter-apk/app-release.apk.sha1 .releases

fmt_ver=$(sed 's/\./\-/g' <<< $1)

rl_date=$(date +%Y-%m-%d)

rename app-release khaata-v$fmt_ver-release-$rl_date .releases/app-release.apk
rename app-release khaata-v$fmt_ver-release-$rl_date .releases/app-release.apk.sha1
