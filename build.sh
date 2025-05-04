#!/bin/bash
# Simple script to configure and build the project using CMake and Ninja.

# Exit immediately if a command exits with a non-zero status.
set -e

# Define the build directory.
BUILD_DIR="build"

# Create the build directory if it doesn't exist.
mkdir -p "${BUILD_DIR}"

# Navigate to the build directory.
cd "${BUILD_DIR}"

# Configure the project using CMake, specifying Ninja as the generator.
# Pass CMAKE_OSX_DEPLOYMENT_TARGET if needed (CMakeLists.txt should set it ideally).
echo "Configuring project with CMake and Ninja..."
cmake -G Ninja ..

# Build the project using Ninja.
echo "Building project with Ninja..."
ninja

echo "Build complete. The application bundle can be found in ${BUILD_DIR}/FinderUI.app" 