#!/bin/bash
# Usage: ./scripts/release.sh 1.0.0
# Creates a git tag and pushes it, triggering the GitHub Release workflow.

set -e

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "Usage: ./scripts/release.sh <version>"
    echo "  Example: ./scripts/release.sh 1.0.0"
    echo "  Example: ./scripts/release.sh 1.1.0-beta.1"
    echo ""
    echo "Current tags:"
    git tag --sort=-creatordate | head -5
    exit 1
fi

# Validate semver format
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.]+)?$ ]]; then
    echo "Error: Version must be semver (e.g. 1.0.0, 1.1.0-beta.1)"
    exit 1
fi

# Check we're on main
BRANCH=$(git branch --show-current)
if [ "$BRANCH" != "main" ]; then
    echo "Warning: You're on '$BRANCH', not 'main'. Continue? (y/n)"
    read -r response
    if [ "$response" != "y" ]; then
        exit 1
    fi
fi

# Check working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo "Error: Working directory has uncommitted changes. Commit or stash first."
    exit 1
fi

# Build + test before tagging
echo "Building..."
swift build -c release
echo "Testing..."
swift test

echo ""
echo "Creating tag v${VERSION}..."
git tag -a "v${VERSION}" -m "Release v${VERSION}"

echo "Pushing tag..."
git push origin "v${VERSION}"

echo ""
echo "Done! Release v${VERSION} will be created by GitHub Actions."
echo "  -> https://github.com/pacosw1/DonkeyUI/releases"
