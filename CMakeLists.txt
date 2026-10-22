cmake_minimum_required(VERSION 3.20)
project(ro-kde-systemsettings VERSION 0.1.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(GNUInstallDirs)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickWidgets Widgets QuickControls2)

# Preload override library
set(LOADER_SOURCES
    overrides/qml/systemsettings_loader.cpp
)

# Compile RCC resources into C++ code to embed inside the shared object
qt6_add_resources(RCC_SOURCES overrides/qml/overrides.qrc)

add_library(systemsettings_override SHARED
    ${LOADER_SOURCES}
    ${RCC_SOURCES}
)

set_target_properties(systemsettings_override PROPERTIES
    OUTPUT_NAME "systemsettings_override"
    PREFIX "lib"
)

target_include_directories(systemsettings_override PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/overrides/qml
)

target_link_options(systemsettings_override PRIVATE "LINKER:--no-undefined")

target_link_libraries(systemsettings_override PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Quick
    Qt6::Qml
    Qt6::QuickWidgets
    Qt6::Widgets
    Qt6::QuickControls2
    ${CMAKE_DL_LIBS}
)

# Also generate binary RCC file overrides.rcc
find_program(RCC_EXECUTABLE NAMES rcc-qt6 rcc HINTS /usr/lib64/qt6/libexec)
if(NOT RCC_EXECUTABLE)
    message(FATAL_ERROR "rcc executable not found")
endif()

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/overrides.rcc
    COMMAND ${RCC_EXECUTABLE} -binary ${CMAKE_CURRENT_SOURCE_DIR}/overrides/qml/overrides.qrc -o ${CMAKE_CURRENT_BINARY_DIR}/overrides.rcc
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/overrides/qml/overrides.qrc
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/overrides/qml
    COMMENT "Compiling binary overrides.rcc"
)
add_custom_target(generate_rcc ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/overrides.rcc)

# Translations (.po -> .mo)
find_program(MSGFMT_EXECUTABLE msgfmt)
if(NOT MSGFMT_EXECUTABLE)
    message(FATAL_ERROR "msgfmt executable not found")
endif()

set(PO_FILES
    overrides/translations/kcm_landingpage.po
    overrides/translations/kcmqtquicksettings.po
    overrides/translations/systemsettings.po
    overrides/translations/kcm_nighttime.po
)

set(MO_TARGETS "")
foreach(po_file ${PO_FILES})
    get_filename_component(name ${po_file} NAME_WE)
    set(mo_file ${CMAKE_CURRENT_BINARY_DIR}/locale/tr/LC_MESSAGES/${name}.mo)
    add_custom_command(
        OUTPUT ${mo_file}
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_CURRENT_BINARY_DIR}/locale/tr/LC_MESSAGES
        COMMAND ${MSGFMT_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/${po_file} -o ${mo_file}
        DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${po_file}
        COMMENT "Compiling translation ${name}.mo"
    )
    list(APPEND MO_TARGETS ${mo_file})
endforeach()
add_custom_target(generate_translations ALL DEPENDS ${MO_TARGETS})

# Install targets
# 1. Shared library
install(TARGETS systemsettings_override
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/ro-kde-systemsettings
)

# 2. Binary RCC
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/overrides.rcc
    DESTINATION ${CMAKE_INSTALL_DATADIR}/ro-kde-systemsettings
)

# 3. tabs.qss
install(FILES overrides/theme/tabs.qss
    DESTINATION ${CMAKE_INSTALL_DATADIR}/ro-kde-systemsettings
)

# 4. QML overrides & components
install(DIRECTORY overrides/qml/
    DESTINATION ${CMAKE_INSTALL_DATADIR}/ro-kde-systemsettings/qml
    PATTERN "*.cpp" EXCLUDE
    PATTERN "*.qrc" EXCLUDE
    PATTERN "*.so" EXCLUDE
    PATTERN "*.rcc" EXCLUDE
)

# 5. Nav module in QML imports directory
install(DIRECTORY overrides/qml/imports/org
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/ro-kde-systemsettings/qml
    PATTERN "*.so" EXCLUDE
)

# 6. Category desktop files
install(DIRECTORY overrides/metadata/categories/
    DESTINATION ${CMAKE_INSTALL_DATADIR}/ro-kde-systemsettings/systemsettings/categories
    FILES_MATCHING PATTERN "*.desktop"
)

# 7. Translations
install(DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/locale/
    DESTINATION ${CMAKE_INSTALL_DATADIR}/ro-kde-systemsettings/locale
)

# 8. ro-systemsettings wrapper script
install(PROGRAMS bin/ro-systemsettings
    DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# 9. Desktop entries
install(FILES packaging/fedora/ro-systemsettings.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/applications
)
install(FILES packaging/fedora/systemsettings.desktop
    DESTINATION ${CMAKE_INSTALL_DATADIR}/ro-kde-systemsettings/applications
)
