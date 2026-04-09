#
#
#
cmake_minimum_required(VERSION 3.24)
set(PROJECT_PREFIX OWLDRONE)
set(PROJECT_PREFIX_LOWER owldrone)
set(ENGINE_NAME OwlEngine)
project(OwlDrone VERSION 0.0.1 LANGUAGES C CXX)
#
# ---=== Options ===---
#
option(${PROJECT_PREFIX}_BUILD_SHARED "If the engine was built as shared library" ON)
option(${PROJECT_PREFIX}_USE_RELEASE_THIRD_PARTY "Use release version of third party libraries" ON)

#
# ---=== Base Configs ===---

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake" "${CMAKE_MODULE_PATH}")
include(BaseConfig)

#
# ---=== The Program ===---
#
file(GLOB_RECURSE SRCS
        sources/*.cpp
)
file(GLOB_RECURSE HDRS
        sources/*.h
)
add_executable(${CMAKE_PROJECT_NAME}
        ${SRCS} ${HDRS})
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set_target_properties(${CMAKE_PROJECT_NAME} PROPERTIES FOLDER "App")

target_include_directories(${CMAKE_PROJECT_NAME} PRIVATE sources)

target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE
        ${CMAKE_PROJECT_NAME}_Base
)

target_compile_definitions(${CMAKE_PROJECT_NAME} PRIVATE OWL_ASSETS_LOCATION="assets")

target_import_so_files(${CMAKE_PROJECT_NAME})

# ----==== third party ====----

if (${PROJECT_PREFIX}_USE_RELEASE_THIRD_PARTY)
    set(THIRD_PARTY_RELEASE FORCE_RELEASE)
endif ()

# OwlEngine
owl_target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE OwlEngine REQUIRED ${THIRD_PARTY_RELEASE})

if (${PROJECT_PREFIX}_PLATFORM_WINDOWS)
    # for web cam identification
    target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE strmiids)
endif ()

# yaml
owl_target_link_libraries(${CMAKE_PROJECT_NAME} PRIVATE yaml-cpp REQUIRED ${THIRD_PARTY_RELEASE})

# ----==== third party ====----

if (${PROJECT_PREFIX}_BUILD_SHARED AND WIN32)
    add_custom_command(TARGET ${CMAKE_PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different "$<TARGET_RUNTIME_DLLS:${CMAKE_PROJECT_NAME}>" "$<TARGET_FILE_DIR:${CMAKE_PROJECT_NAME}>"
            COMMAND_EXPAND_LISTS
    )
endif ()

add_custom_command(TARGET ${CMAKE_PROJECT_NAME} PRE_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different "${CMAKE_CURRENT_SOURCE_DIR}/imgui.ini" "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/OwlDrone_imgui.ini"
        VERBATIM)

install(TARGETS ${CMAKE_PROJECT_NAME}
        LIBRARY DESTINATION ${${PROJECT_PREFIX}_INSTALL_BIN}
        RUNTIME DESTINATION ${${PROJECT_PREFIX}_INSTALL_BIN}
        FRAMEWORK DESTINATION ${${PROJECT_PREFIX}_INSTALL_BIN}
)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/assets/
        DESTINATION assets
)

#
# ---=== CLEANING PROCEDURES ===---
#
add_custom_target(clean_bin
        COMMAND ${CMAKE_COMMAND} -E remove_directory "${CMAKE_BINARY_DIR}/bin"
        COMMAND ${CMAKE_COMMAND} -E make_directory "${CMAKE_BINARY_DIR}/bin"
        COMMENT "Cleaning the binary directory ${CMAKE_BINARY_DIR}/bin"
)
set_target_properties(clean_bin PROPERTIES FOLDER "Utils")
