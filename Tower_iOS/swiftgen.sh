#!/usr/bin/env bash

#
# swiftgen.sh
# Tower_iOS
#
# Created by Jean-Pierre Höhmann on 2023-04-05.
#
#

#
# Code Generation
#
# This script generates code from the Core Data model, XCode assets and
# resources.
#

set +euo pipefail

# shellcheck disable=SC2164
cd "${SRCROOT}/Tower_iOS"

exec swiftgen
