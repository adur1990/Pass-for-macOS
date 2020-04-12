#!/bin/bash

set -eox pipefail

echo "Starting archivation process."

APP_NAME="Pass for macOS.app"
BUILD_PATH=$PWD/build
ARCHIVE_PATH=$BUILD_PATH/passformacos.xcarchive
EXPORT_OPTIONS=$PWD/.github/templates/export_options.plist

echo "Building app."
xcodebuild -project passformacos.xcodeproj/ \
    -scheme passformacos \
    -sdk macosx \
    -configuration Release \
    -archivePath $ARCHIVE_PATH \
    clean archive

echo "Signing app."
xcodebuild -exportArchive \
    -archivePath $ARCHIVE_PATH \
    -exportOptionsPlist $EXPORT_OPTIONS \
    -exportPath $BUILD_PATH

SIGNATURE=$(codesign -vvvv "$BUILD_PATH/$APP_NAME" 2>&1)

if [[ $SIGNATURE != *"satisfies its Designated Requirement"* ]]; then
    echo "Signature is not correct. Stopping!"
    exit 1
fi

echo "Signature is correct. Packing app."

cd $BUILD_PATH/
ditto -c -k --sequesterRsrc --keepParent "$APP_NAME" "$APP_NAME.zip"

mv "$APP_NAME.zip" ../

echo "Done archiving Pass for macOS."
