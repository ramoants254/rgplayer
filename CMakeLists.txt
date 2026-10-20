cmake_minimum_required(VERSION 3.28)

project(rgplayer VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(Qt6 6.8 REQUIRED COMPONENTS Quick DBus Test)
find_package(PkgConfig REQUIRED)
pkg_check_modules(MPV REQUIRED IMPORTED_TARGET mpv)

qt_standard_project_setup(REQUIRES 6.8)

set_source_files_properties(qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

qt_add_executable(rgplayer
    src/main.cpp
    src/app/player_controller.cpp
    src/app/player_controller.h
    src/app/playlist_model.cpp
    src/app/playlist_model.h
    src/app/thumbnail_service.cpp
    src/app/thumbnail_service.h
    src/app/mpris_service.cpp
    src/app/mpris_service.h
    src/core/mpv_wrapper.cpp
    src/core/mpv_wrapper.h
)

qt_add_qml_module(rgplayer
    URI Rgplayer
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        qml/Theme.qml
        qml/components/PlaybackBar.qml
        qml/components/Osd.qml
        qml/components/PlaylistDrawer.qml
        qml/components/SettingsPage.qml
        qml/components/ThemeCheckBox.qml
        qml/components/ThemeSlider.qml
        qml/components/ThemeButton.qml
    SOURCES
        src/core/mpv_render_item.cpp
        src/core/mpv_render_item.h
)

target_link_libraries(rgplayer PRIVATE Qt6::Quick Qt6::DBus PkgConfig::MPV)
target_include_directories(rgplayer PRIVATE src src/core)

set_target_properties(rgplayer PROPERTIES
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

include(GNUInstallDirs)
install(TARGETS rgplayer
    BUNDLE DESTINATION .
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

install(FILES resources/rgplayer.desktop DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications)
install(FILES resources/rgplayer.xml DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/mime/packages)
install(FILES resources/org.rgplayer.rgplayer.metainfo.xml
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/metainfo)

set(CPACK_PACKAGE_NAME "rgplayer")
set(CPACK_PACKAGE_VENDOR "rgplayer")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Keyboard-driven Linux media player")
set(CPACK_PACKAGE_CONTACT "rgplayer maintainers")
set(CPACK_PACKAGE_VERSION ${PROJECT_VERSION})
set(CPACK_GENERATOR "DEB")
set(CPACK_DEBIAN_PACKAGE_DEPENDS "libmpv2 | libmpv1")
set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)
include(CPack)

include(CTest)
if(BUILD_TESTING)
    add_executable(playlist_model_test
        tests/playlist_model_test.cpp
        src/app/playlist_model.cpp
        src/app/playlist_model.h
    )
    target_link_libraries(playlist_model_test PRIVATE Qt6::Core Qt6::Test)
    target_include_directories(playlist_model_test PRIVATE src src/app)
    add_test(NAME playlist_model_test COMMAND playlist_model_test)
endif()
