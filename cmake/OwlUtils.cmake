
function(target_import_so_files TARGET)
    if (${PROJECT_PREFIX}_PLATFORM_LINUX)
        get_target_property(TARGET_TYPE ${TARGET} TYPE)
        if (${TARGET_TYPE} STREQUAL "EXECUTABLE" OR ${TARGET_TYPE} STREQUAL "SHARED_LIBRARY")
            message(STATUS "Target: ${TARGET} of type ${TARGET_TYPE}: copy additional shared libs.")
            add_custom_command(TARGET ${TARGET} POST_BUILD
                    COMMAND ${Python3_EXECUTABLE} -u ${PROJECT_SOURCE_DIR}/cmake/importSharedLibs.py
                    "$<TARGET_FILE:${TARGET}>" \"${CMAKE_PREFIX_PATH}\"
                    COMMENT "Copy the needed shared libraries"
                    USES_TERMINAL
            )
        endif ()
    endif ()
endfunction()

function(pretty_platform_str INVAR OUTVAR)
    string(REPLACE "Darwin" "MacOS" TMP "${INVAR}")
    string(TOLOWER "${TMP}" TMP)
    set(${OUTVAR} ${TMP} PARENT_SCOPE)
endfunction()

function(pretty_architecture_str INVAR OUTVAR)
    if (INVAR MATCHES "(AMD64|amd64|x86_64|x64)")
        set(${OUTVAR} "x64" PARENT_SCOPE)
    elseif (INVAR MATCHES "(ARM64|arm64|aarch64)")
        set(${OUTVAR} "arm64" PARENT_SCOPE)
    else ()
        set(${OUTVAR} ${INVAR} PARENT_SCOPE)
    endif ()
endfunction()

function(print_system_n_target_infos)
    message(STATUS "---------- HOST SYSTEM ---------")
    message(STATUS " OS       : ${${PROJECT_PREFIX}_HOST_PLATFORM_STR}")
    message(STATUS " ARCH     : ${${PROJECT_PREFIX}_HOST_ARCH_STR}")
    message(STATUS " VERSION  : ${CMAKE_HOST_SYSTEM_VERSION}")
    message(STATUS "--------- TARGET SYSTEM --------")
    message(STATUS " OS       : ${${PROJECT_PREFIX}_PLATFORM_STR}")
    message(STATUS " ARCH     : ${${PROJECT_PREFIX}_ARCH_STR}")
    message(STATUS " COMPILER : ${${PROJECT_PREFIX}_COMPILER_STR} - ${CMAKE_CXX_COMPILER_VERSION} (${CMAKE_CXX_COMPILER})")
    if (NOT ${CMAKE_CXX_COMPILER_TARGET} STREQUAL "")
        message(STATUS " TARGET   : ${CMAKE_CXX_COMPILER_TARGET}")
    endif ()
    if (NOT ${CMAKE_CXX_COMPILER_ABI} STREQUAL "")
        message(STATUS " ABI      : ${CMAKE_CXX_COMPILER_ABI}")
    endif ()
    if (NOT ${CMAKE_CXX_COMPILER_ARCHITECTURE_ID} STREQUAL "")
        message(STATUS " ARCH     : ${CMAKE_CXX_COMPILER_ARCHITECTURE_ID}")
    endif ()
    message(STATUS " LINKER   : ${CMAKE_CXX_COMPILER_LINKER_ID} - ${CMAKE_CXX_COMPILER_LINKER_VERSION} (${CMAKE_CXX_COMPILER_LINKER})")
    message(STATUS " FEATURES : ${CMAKE_CXX_COMPILE_FEATURES}")
    message(STATUS " FLAGS    : ${CMAKE_CXX_FLAGS}")
    message(STATUS "--------------------------------")
endfunction()

function(owl_target_link_libraries Target LinkType Module)
    if (NOT TARGET ${Module}::${Module})
        message(STATUS "Loading ${Module}....")

        set(FindPackageArgs "")
        set(ForceRelease OFF)
        set(ModuleTarget "${Module}::${Module}") # Valeur par défaut
        foreach (arg IN LISTS ARGV)
            if (arg STREQUAL "REQUIRED" OR
                    arg STREQUAL "QUIET" OR
                    arg STREQUAL "CONFIG" OR
                    arg MATCHES "^[0-9]+\\.[0-9]+.*"
            )
                list(APPEND FindPackageArgs ${arg})
            elseif (arg STREQUAL FORCE_RELEASE)
                set(ForceRelease ON)
            elseif (arg STREQUAL MODULE_TARGET)
                list(FIND ARGV MODULE_TARGET index)
                math(EXPR next_index "${index} + 1")
                list(GET ARGV ${next_index} ModuleTarget)
            endif ()
        endforeach ()

        if (ForceRelease)
            set(StateSave ${CMAKE_MAP_IMPORTED_CONFIG_DEBUG})
            set(CMAKE_MAP_IMPORTED_CONFIG_DEBUG Release)
        endif ()
        find_package(${Module} ${FindPackageArgs})
        if (ForceRelease)
            set(CMAKE_MAP_IMPORTED_CONFIG_DEBUG ${StateSave})
        endif ()
        if (NOT TARGET ${ModuleTarget})
            message(FATAL_ERROR "Module ${ModuleTarget} not found. Please ensure it is built and available in the CMake path.")
        endif ()
        message(STATUS "Found ${Module} version ${${Module}_VERSION} @ ${${Module}_DIR}")
    endif ()

    string(STRIP ${LinkType} LinkType)
    if (NOT ("${LinkType}" STREQUAL "PRIVATE" OR
            "${LinkType}" STREQUAL "PUBLIC" OR
            "${LinkType}" STREQUAL "INTERFACE"))
        message(FATAL_ERROR "LinkType must be one of 'PRIVATE', 'PUBLIC', or 'INTERFACE'. Provided: '${LinkType}'")
    endif ()

    target_link_libraries(${Target} ${LinkType} ${ModuleTarget})
endfunction()
