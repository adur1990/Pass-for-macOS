#!/bin/sh
set -eox pipefail

gpg --quiet --batch --yes --decrypt --passphrase="$APP_PROFILE_PASSPHRASE" --output ./.github/secrets/Pass_for_macOS.provisionprofile ./.github/secrets/Pass_for_macOS.provisionprofile.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$EXTENSION_PROFILE_PASSPHRASE" --output ./.github/secrets/Pass_for_macOS_Extension.provisionprofile ./.github/secrets/Pass_for_macOS_Extension.provisionprofile.gpg
gpg --quiet --batch --yes --decrypt --passphrase="$DEV_ID_PASSPHRASE" --output ./.github/secrets/developer_id.p12 ./.github/secrets/developer_id.p12.gpg

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles
cp ./.github/secrets/Pass_for_macOS.provisionprofile ~/Library/MobileDevice/Provisioning\ Profiles/Pass_for_macOS.provisionprofile
cp ./.github/secrets/Pass_for_macOS_Extension.provisionprofile ~/Library/MobileDevice/Provisioning\ Profiles/Pass_for_macOS_Extension.provisionprofile

security create-keychain -p "" build.keychain
security import ./.github/secrets/developer_id.p12 -t agg -k ~/Library/Keychains/build.keychain -P "$DEV_ID_PASSPHRASE" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain

security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain
