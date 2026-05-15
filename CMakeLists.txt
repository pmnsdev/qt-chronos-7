cmake_minimum_required(VERSION 3.21)

project(ChronosDisplay VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(appChronosDisplay
    src/main.cpp
    ChronosDisplay.qrc
)

target_link_libraries(appChronosDisplay
    PRIVATE
        Qt6::Core
        Qt6::Gui
        Qt6::Quick
        Qt6::Qml
        Qt6::QuickControls2
)

set_target_properties(appChronosDisplay PROPERTIES
    WIN32_EXECUTABLE TRUE
    MACOSX_BUNDLE TRUE
)
