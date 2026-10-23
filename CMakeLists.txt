# SPDX-License-Identifier: GPL-3.0-or-later
cmake_minimum_required(VERSION 3.22)
project(ro-kde-systemsettings VERSION 0.2.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
include(GNUInstallDirs)
find_package(Qt6 6.6 REQUIRED COMPONENTS Widgets QuickWidgets QuickControls2 Test)
find_package(KF6CoreAddons 6.0 REQUIRED)
find_package(KF6Config 6.0 REQUIRED)
find_package(KF6KCMUtils 6.0 REQUIRED)
find_package(KF6Auth 6.0 REQUIRED)
find_package(KF6I18n 6.0 REQUIRED)
set_source_files_properties(src/qml/Main.qml PROPERTIES QT_RESOURCE_ALIAS Main.qml)
set_source_files_properties(src/qml/ModuleHeader.qml PROPERTIES QT_RESOURCE_ALIAS ModuleHeader.qml)
qt_add_executable(ro-systemsettings src/main.cpp src/shell.cpp src/shell.h)
qt_add_qml_module(ro-systemsettings
    URI org.ro.systemsettings VERSION 1.0
    RESOURCE_PREFIX /ro
    QML_FILES src/qml/Main.qml src/qml/ModuleHeader.qml)
target_link_libraries(ro-systemsettings PRIVATE Qt6::Widgets Qt6::QuickWidgets
    Qt6::QuickControls2 KF6::CoreAddons KF6::ConfigCore KF6::KCMUtils
    KF6::AuthCore KF6::I18n)
target_compile_definitions(ro-systemsettings PRIVATE RO_VERSION="${PROJECT_VERSION}")
install(TARGETS ro-systemsettings RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES packaging/fedora/ro-systemsettings.desktop DESTINATION ${CMAKE_INSTALL_DATADIR}/applications)
include(CTest)
if(BUILD_TESTING)
    add_library(ro_test_kcm MODULE tests/test_kcm.cpp)
    set_target_properties(ro_test_kcm PROPERTIES PREFIX "" LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/test-plugins/plasma/kcms/systemsettings")
    target_link_libraries(ro_test_kcm PRIVATE KF6::KCMUtils KF6::ConfigCore)
    qt_add_executable(ro-shell-tests tests/test_shell.cpp src/shell.cpp src/shell.h)
    target_include_directories(ro-shell-tests PRIVATE src)
    target_link_libraries(ro-shell-tests PRIVATE Qt6::Test Qt6::Widgets Qt6::QuickWidgets Qt6::QuickControls2
        KF6::CoreAddons KF6::ConfigCore KF6::KCMUtils KF6::AuthCore KF6::I18n)
    qt_add_qml_module(ro-shell-tests URI org.ro.systemsettings VERSION 1.0 RESOURCE_PREFIX /ro
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/test-qml/org/ro/systemsettings
        QML_FILES src/qml/Main.qml src/qml/ModuleHeader.qml)
    add_dependencies(ro-shell-tests ro_test_kcm)
    add_test(NAME shell-behavior COMMAND bash ${CMAKE_CURRENT_SOURCE_DIR}/tests/run-shell-unit.sh ${CMAKE_BINARY_DIR})
    add_test(NAME shell-behavior-tr COMMAND bash ${CMAKE_CURRENT_SOURCE_DIR}/tests/run-shell-unit.sh ${CMAKE_BINARY_DIR} tr_TR.UTF-8)
    add_test(NAME source-contract COMMAND python3 ${CMAKE_CURRENT_SOURCE_DIR}/tests/test-shell-source.py)
endif()
