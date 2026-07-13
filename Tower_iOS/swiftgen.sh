#!/usr/bin/env bash

#
# swiftgen.sh
# Tower_iOS
#
#
#

#
# Code Generation
#
# This script generates code from the Core Data model, XCode assets and
# resources.
#

set -euo pipefail

# shellcheck disable=SC2164
cd "${SRCROOT}/Tower_iOS"

if [[ -f "${PODS_ROOT}/SwiftGen/bin/swiftgen" ]]; then
  exec "${PODS_ROOT}/SwiftGen/bin/swiftgen"
else
  echo "error: SwiftGen is not installed. Run 'pod install --repo-update' to install it." >&2
  exit 1
fi
