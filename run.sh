#!/bin/bash
# Simple script to build and run the application.

# Exit immediately if a command exits with a non-zero status.
set -e

# Run the build script first.
./build.sh

# Define the path to the application bundle.
# Note: CMake typically puts the bundle in the build directory.
APP_BUNDLE="build/FinderUI.app"

# Check if the application bundle exists.
if [ ! -d "${APP_BUNDLE}" ]; then
    echo "Error: Application bundle not found at ${APP_BUNDLE}"
    exit 1
fi

# Run the application.
echo "Running application: ${APP_BUNDLE}"
open "${APP_BUNDLE}"

echo "Application launched." 