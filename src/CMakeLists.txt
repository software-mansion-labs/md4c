set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS 1)

# Handle absolute include and lib dirs outside of CMAKE_INSTALL_PREFIX
include(JoinPaths.cmake) # can be replaced by cmake_path(APPEND) in CMake 3.20
join_paths(PKGCONFIG_INCLUDEDIR "\${prefix}" "${CMAKE_INSTALL_INCLUDEDIR}")
join_paths(PKGCONFIG_LIBDIR "\${prefix}" "${CMAKE_INSTALL_LIBDIR}")

# Build & install rules for MD4C parser library
configure_file(enrmrkd.pc.in enrmrkd.pc @ONLY)
add_library(enrmrkd enrmrkd.c enrmrkd.h)
target_include_directories(enrmrkd PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
)
target_compile_definitions(enrmrkd PRIVATE "$<$<CONFIG:Debug>:DEBUG>")
set_target_properties(enrmrkd PROPERTIES
    VERSION ${PROJECT_VERSION}
    SOVERSION ${PROJECT_VERSION_MAJOR}
    PUBLIC_HEADER enrmrkd.h
)
install(
    TARGETS enrmrkd
    EXPORT enrmrkdConfig
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/enrmrkd.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)

# Build & install rules for HTML renderer library
if(BUILD_HTML_LIBRARY)
    configure_file(enrmrkd-html.pc.in enrmrkd-html.pc @ONLY)
    add_library(enrmrkd-html enrmrkd-html.c enrmrkd-html.h enrmrkd-entity.c enrmrkd-entity.h)
    target_include_directories(enrmrkd-html PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>"
        "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>"
    )
    set_target_properties(enrmrkd-html PROPERTIES
        VERSION ${PROJECT_VERSION}
        SOVERSION ${PROJECT_VERSION_MAJOR}
        PUBLIC_HEADER enrmrkd-html.h
    )
    target_link_libraries(enrmrkd-html PUBLIC enrmrkd)
    install(
        TARGETS enrmrkd-html
        EXPORT enrmrkdConfig
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/enrmrkd-html.pc DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig)
endif()

# Install rules
install(EXPORT enrmrkdConfig DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/enrmrkd/ NAMESPACE enrmrkd::)
