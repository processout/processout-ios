#!/bin/bash

set -e

VERSION=$(cat Version.resolved)
VERSION_REGEX="^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$"

if [[ $VERSION =~ $VERSION_REGEX ]]; then
    MAJOR="${BASH_REMATCH[1]}"
    MINOR="${BASH_REMATCH[2]}"
    PATCH="${BASH_REMATCH[3]}"
    if [[ "$@" =~ '--patch' ]]; then
        PATCH=$((PATCH + 1))
    fi
    if [[ "$@" =~ '--minor' ]]; then
        MINOR=$((MINOR + 1))
        PATCH=0
    fi
    VERSION="${MAJOR}.${MINOR}.${PATCH}"
else
    echo "Resolved version is invalid."
    exit -1
fi

# Writes resolved version to file
echo $VERSION > Version.resolved

# Generates ProcessOut+Version.swift
cat > "Sources/ProcessOut/Sources/Generated/ProcessOutApi+Version.swift" <<- EOF
//
// ProcessOutApi+Version.swift
//
// This file was generated by UpdateVersion.sh
// Do not edit this file directly.
//

extension ProcessOutApi {

    /// The current version of this library.
    public static let version = "${VERSION}"
}
EOF

# Updates version in podspec
sed -Ei "" "s|(s[.]version *= *)'(.*)'|\1'$VERSION'|" ProcessOut.podspec

# Triggers project bootstrap to ensure that version is updated
source Scripts/BootstrapProject.sh
