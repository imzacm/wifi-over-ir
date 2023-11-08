# Find makerom
if(DEFINED ENV{MAKEROM_DIR})
    find_program(MAKEROM_EXE NAMES makerom HINTS "$ENV{MAKEROM_DIR}")
endif()

if(NOT MAKEROM_EXE)
    find_program(MAKEROM_EXE NAMES makerom HINTS "${DEVKITARM}/bin")
endif()

if(NOT MAKEROM_EXE)
    message(FATAL_ERROR "Cannot find makerom, try installing it or setting the MAKEROM env var")
endif()

# Find bannertool
if(DEFINED ENV{BANNERTOOL_DIR})
    find_program(BANNERTOOL_EXE NAMES bannertool HINTS "$ENV{BANNERTOOL_DIR}")
endif()

if(NOT BANNERTOOL_EXE)
    find_program(BANNERTOOL_EXE NAMES bannertool HINTS "${DEVKITARM}/bin")
endif()

if(NOT BANNERTOOL_EXE)
    message(FATAL_ERROR "Cannot find bannertool, try installing it or setting the BANNERTOOL env var")
endif()

# Find strip
find_program(STRIP_EXE NAMES arm-none-eabi-strip HINTS "${DEVKITARM}/bin")

if(STRIP_EXE)
    message(STATUS "found arm-none-eabi-strip")
else()
    message(WARNING "cannot find arm-none-eabi-strip")
endif()

function(ctr_create_banner)
    cmake_parse_arguments(PARSE_ARGV 0 BANNER "" "OUTPUT;IMAGE;AUDIO" "")

    if(NOT DEFINED BANNER_OUTPUT)
        if(DEFINED BANNER_UNPARSED_ARGUMENTS)
            list(GET BANNER_UNPARSED_ARGUMENTS 0 BANNER_OUTPUT)
        else()
            message(FATAL_ERROR "ctr_create_banner: missing OUTPUT argument")
        endif()
    endif()

    if(NOT DEFINED BANNER_IMAGE)
        if(DEFINED BANNER_UNPARSED_ARGUMENTS)
            list(GET BANNER_UNPARSED_ARGUMENTS 1 BANNER_IMAGE)
        else()
            message(FATAL_ERROR "ctr_create_banner: missing IMAGE argument")
        endif()
    endif()

    if(NOT DEFINED BANNER_AUDIO)
        if(DEFINED BANNER_UNPARSED_ARGUMENTS)
            list(GET BANNER_UNPARSED_ARGUMENTS 2 BANNER_AUDIO)
        else()
            message(FATAL_ERROR "ctr_create_banner: missing AUDIO argument")
        endif()
    endif()

    get_filename_component(BANNER_IMAGE "${BANNER_IMAGE}" ABSOLUTE)
    get_filename_component(BANNER_AUDIO "${BANNER_AUDIO}" ABSOLUTE)
    get_filename_component(BANNER_OUTPUT "${BANNER_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")

    add_custom_command(
        OUTPUT "${BANNER_OUTPUT}"
        COMMAND "${BANNERTOOL_EXE}" makebanner -i "${BANNER_IMAGE}" -a "${BANNER_AUDIO}" -o "${BANNER_OUTPUT}"
        DEPENDS "${BANNER_IMAGE}" "${BANNER_AUDIO}"
        VERBATIM)
endfunction()

function(ctr_create_cia target)
    cmake_parse_arguments(PARSE_ARGV 1 CIA "STRIP" "TARGET;OUTPUT;RSF;BANNER;ICON;RSF_TITLE;RSF_PRODUCT_CODE;RSF_UNIQUE_ID;RSF_SYSTEM_MODE;RSF_SYSTEM_MODE_EXT;RSF_CATEGORY;RSF_USE_ON_SD;RSF_MEMORY_TYPE;RSF_CPU_SPEED;RSF_ENABLE_L2_CACHE" "")

    if(DEFINED CIA_TARGET)
        set(CIA_IN_TARGET "${CIA_TARGET}")
        set(CIA_OUT_TARGET "${target}")
    else()
        set(CIA_IN_TARGET "${target}")
        set(CIA_OUT_TARGET "${target}_cia")
    endif()

    if(NOT TARGET "${CIA_IN_TARGET}")
        message(FATAL_ERROR "ctr_create_cia: target '${CIA_IN_TARGET}' not defined")
    endif()

    if(DEFINED CIA_OUTPUT)
        get_filename_component(CIA_OUTPUT "${CIA_OUTPUT}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_BINARY_DIR}")
    else()
        set(CIA_OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${CIA_OUT_TARGET}.cia")
    endif()

    set(CIA_MAKEROM_ARGS
        -f cia
        -target t
        -exefslogo
        -o "${CIA_OUTPUT}")
    set(CIA_MAKEROM_DEPS "${CIA_IN_TARGET}")

    if(DEFINED CIA_RSF)
        get_filename_component(CIA_RSF "${CIA_RSF}" ABSOLUTE)
        list(APPEND CIA_MAKEROM_ARGS -rsf "${CIA_RSF}")
        list(APPEND CIA_MAKEROM_DEPS "${CIA_RSF}")
    else()
        get_filename_component(CIA_RSF "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/3DS-template-cia.rsf" ABSOLUTE)
        list(APPEND CIA_MAKEROM_ARGS
            -rsf "${CIA_RSF}"
            -major "${CMAKE_PROJECT_VERSION_MAJOR}"
            -minor "${CMAKE_PROJECT_VERSION_MINOR}"
            -micro "${CMAKE_PROJECT_VERSION_PATCH}"
            "-DAPP_VERSION_MAJOR=${CMAKE_PROJECT_VERSION_MAJOR}"
            -DAPP_ENCRYPTED=false)
        list(APPEND CIA_MAKEROM_DEPS "${CIA_RSF}")

        if(DEFINED CIA_RSF_TITLE)
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_TITLE=${CIA_RSF_TITLE}")
        else()
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_TITLE=${CMAKE_PROJECT_NAME}")
        endif()

        if(DEFINED CIA_RSF_PRODUCT_CODE)
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_PRODUCT_CODE=${CIA_RSF_PRODUCT_CODE}")
        endif()

        if(DEFINED CIA_RSF_UNIQUE_ID)
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_UNIQUE_ID=${CIA_RSF_UNIQUE_ID}")
        endif()

        if(DEFINED CIA_RSF_SYSTEM_MODE)
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_SYSTEM_MODE=${CIA_RSF_SYSTEM_MODE}")
        else()
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_SYSTEM_MODE=64MB")
        endif()

        if(DEFINED CIA_RSF_SYSTEM_MODE_EXT)
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_SYSTEM_MODE_EXT=${CIA_RSF_SYSTEM_MODE_EXT}")
        else()
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_SYSTEM_MODE_EXT=Legacy")
        endif()

        if(DEFINED CIA_RSF_CATEGORY)
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_CATEGORY=${CIA_RSF_CATEGORY}")
        else()
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_CATEGORY=Application")
        endif()

        if(DEFINED CIA_RSF_USE_ON_SD)
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_USE_ON_SD=${CIA_RSF_USE_ON_SD}")
        else()
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_USE_ON_SD=true")
        endif()

        if(DEFINED CIA_RSF_MEMORY_TYPE)
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_MEMORY_TYPE=${CIA_RSF_MEMORY_TYPE}")
        else()
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_MEMORY_TYPE=Application")
        endif()

        if(DEFINED CIA_RSF_CPU_SPEED)
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_CPU_SPEED=${CIA_RSF_CPU_SPEED}")
        else()
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_CPU_SPEED=268MHz")
        endif()

        if(DEFINED CIA_RSF_ENABLE_L2_CACHE)
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_ENABLE_L2_CACHE=${CIA_RSF_ENABLE_L2_CACHE}")
        else()
            list(APPEND CIA_MAKEROM_ARGS "-DAPP_ENABLE_L2_CACHE=false")
        endif()
    endif()

    if(DEFINED CIA_BANNER)
        get_filename_component(CIA_BANNER "${CIA_BANNER}" ABSOLUTE)
        list(APPEND CIA_MAKEROM_ARGS -banner "${CIA_BANNER}")
        list(APPEND CIA_MAKEROM_DEPS "${CIA_BANNER}")
    endif()

    if(DEFINED CIA_ICON)
        get_filename_component(CIA_ICON "${CIA_ICON}" ABSOLUTE)
        list(APPEND CIA_MAKEROM_ARGS -icon "${CIA_ICON}")
        list(APPEND CIA_MAKEROM_DEPS "${CIA_ICON}")
    endif()

    if(STRIP_EXE OR DEFINED CIA_STRIP)
        if(NOT STRIP_EXE)
            message(FATAL_ERROR "ctr_create_cia: cannot find arm-none-eabi-strip")
        endif()

        set(CIA_STRIPPED_ELF "${CMAKE_CURRENT_BINARY_DIR}/${CIA_IN_TARGET}-stripped.elf")
        add_custom_command(
            OUTPUT "${CIA_STRIPPED_ELF}"
            COMMAND "${STRIP_EXE}" -o "${CIA_STRIPPED_ELF}" "$<TARGET_FILE:${CIA_IN_TARGET}>"
            DEPENDS "${CIA_IN_TARGET}"
            VERBATIM)
        list(APPEND CIA_MAKEROM_ARGS -elf "${CIA_STRIPPED_ELF}")
        list(APPEND CIA_MAKEROM_DEPS "${CIA_STRIPPED_ELF}")
    else()
        list(APPEND CIA_MAKEROM_ARGS -elf "$<TARGET_FILE:${CIA_IN_TARGET}>")
        list(APPEND CIA_MAKEROM_DEPS "${CIA_IN_TARGET}")
    endif()

    add_custom_command(
        OUTPUT "${CIA_OUTPUT}"
        COMMAND "${MAKEROM_EXE}" ${CIA_MAKEROM_ARGS}
        DEPENDS ${CIA_MAKEROM_DEPS}
        COMMENT "Building cia target ${CIA_OUT_TARGET}"
        VERBATIM)
    add_custom_target(${CIA_OUT_TARGET} ALL DEPENDS "${CIA_OUTPUT}")
endfunction()
