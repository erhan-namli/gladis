cmake_minimum_required(VERSION 3.16)

project(GLADIS VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# Find Qt6 packages
find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Quick
    Qml
    QuickControls2
    Svg
    Core5Compat
)

# Source files
set(PROJECT_SOURCES
    src/main.cpp
    src/datamanager.cpp
    src/datamanager.h
)

# QML resources
qt6_add_resources(PROJECT_RESOURCES qml.qrc)

# Create executable
add_executable(${PROJECT_NAME}
    ${PROJECT_SOURCES}
    ${PROJECT_RESOURCES}
)

# Link Qt6 libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickControls2
    Qt6::Svg
    Qt6::Core5Compat
)

# Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src
)

# Install target
install(TARGETS ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

# Platform-specific settings
if(CMAKE_CROSSCOMPILING)
    message(STATUS "Cross-compiling for Raspberry Pi 5")

    # Raspberry Pi specific flags
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -march=armv8-a -mtune=cortex-a76")

    # Set Qt6 paths for cross-compilation
    if(NOT DEFINED ENV{QT_HOST_PATH})
        set(ENV{QT_HOST_PATH} "$ENV{HOME}/qt-host")
    endif()

    if(NOT DEFINED Qt6_DIR)
        set(Qt6_DIR "/usr/local/qt6/lib/cmake/Qt6")
    endif()
endif()

# Build type
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

# Compiler flags for optimization
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -O3 -DNDEBUG")
    # Strip symbols in release builds to reduce size
    set(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} -s")
endif()

# Set output directory
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

# Set RPATH for better portability
set(CMAKE_INSTALL_RPATH "\$ORIGIN:\$ORIGIN/lib:\$ORIGIN/../lib")
set(CMAKE_BUILD_RPATH "\$ORIGIN:\$ORIGIN/lib:\$ORIGIN/../lib")
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)
