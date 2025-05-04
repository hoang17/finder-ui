cmake_minimum_required(VERSION 3.15)

project(FinderUI LANGUAGES CXX OBJCXX)

# Set C++ standard (e.g., C++20)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Set Objective-C++ standard if necessary (typically handled by compiler defaults)
# set(CMAKE_OBJCXX_STANDARD 99) # Example, adjust if needed

# --- macOS Specific Settings ---

# Set minimum macOS deployment target (required for modern APIs like sidebar items)
# Using 11.0 for Big Sur features (full-height sidebar, new toolbar items)
set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0")
message(STATUS "macOS Deployment Target: ${CMAKE_OSX_DEPLOYMENT_TARGET}")

# Find necessary macOS Frameworks
find_library(FOUNDATION_LIB Foundation)
find_library(APPKIT_LIB AppKit)

if(NOT FOUNDATION_LIB OR NOT APPKIT_LIB)
    message(FATAL_ERROR "Could not find required Foundation or AppKit frameworks.")
endif()

set(MACOS_FRAMEWORKS
    ${FOUNDATION_LIB}
    ${APPKIT_LIB}
)

# --- Source Files ---

# Define source files for the main application target
set(APP_SOURCES
    src/main.mm
    src/app_delegate.mm
    src/main_window_controller.mm
    src/sidebar_view_controller.mm
    src/content_view_controller.mm
)

# Define header files (useful for IDE integration, not strictly needed for build)
set(APP_HEADERS
    src/app_delegate.h
    src/main_window_controller.h
    src/sidebar_view_controller.h
    src/content_view_controller.h
)

# Group sources and headers in IDEs (like Xcode generated via CMake)
source_group(Headers FILES ${APP_HEADERS})
source_group(Sources FILES ${APP_SOURCES})

# --- Application Target ---

add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${APP_SOURCES} ${APP_HEADERS})

# Set target properties for the application bundle
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/resources/Info.plist.in
    # Sets the name displayed under the icon
    MACOSX_BUNDLE_BUNDLE_NAME "FinderUI"
    # Sets the internal identifier
    MACOSX_BUNDLE_BUNDLE_IDENTIFIER "com.example.finderui"
    # Add other bundle properties as needed
    # MACOSX_BUNDLE_ICON_FILE "YourAppIcon.icns"
    # MACOSX_BUNDLE_SHORT_VERSION_STRING "1.0"
    # MACOSX_BUNDLE_BUNDLE_VERSION "1"
)

# Link the application against the required macOS frameworks
target_link_libraries(${PROJECT_NAME} PRIVATE ${MACOS_FRAMEWORKS})

# --- Build Settings ---

# Enable ARC (Automatic Reference Counting) for Objective-C/C++ files
set_source_files_properties(${APP_SOURCES} PROPERTIES
    COMPILE_FLAGS "-fobjc-arc" # Enable ARC
)

# Optional: Add include directories if needed (e.g., for external libraries)
# target_include_directories(${PROJECT_NAME} PUBLIC include)

# Optional: Set build type if not specified externally (Debug, Release, etc.)
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type (Debug, Release, RelWithDebInfo, MinSizeRel)" FORCE)
endif()

# Output the location of the final bundle
message(STATUS "Application Bundle will be created in ${CMAKE_BINARY_DIR}") 