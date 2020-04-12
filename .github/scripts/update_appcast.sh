#!/usr/bin/env bash

set -exu

VERSION=$(echo $VERSION | cut -d"/" -f3 | cut -d"v" -f2)
DATE="$(date +'%a, %d %b %Y %H:%M:%S %z')"
CHANGELOG=$(cat $PWD/.github/templates/release_notes.md)
SIGNATURE=$(.github/scripts/sign_update -s $SPARKLE_SIGNING_KEY "$PWD/Pass for macOS.app.zip")

echo "
    <item>
      <title>Version $VERSION</title>
      <pubDate>$DATE</pubDate>
      <sparkle:minimumSystemVersion>10.14</sparkle:minimumSystemVersion>
      <description><![CDATA[
$CHANGELOG
      ]]>
      </description>
      <enclosure
        url=\"https://github.com/adur1990/Pass-for-macOS/releases/download/$VERSION/Pass.for.macOS.app.zip\"
        sparkle:version=\"$VERSION\"
        sparkle:shortVersionString=\"$VERSION\"
        $SIGNATURE
        type=\"application/octet-stream\"/>
    </item>
" > ITEM.txt

sed -i '' -e "/<\/language>/r ITEM.txt" appcast.xml
