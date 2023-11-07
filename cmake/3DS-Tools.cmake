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
    cmake_parse_arguments(PARSE_ARGV 1 CIA "STRIP" "TARGET;OUTPUT;RSF;BANNER;ICON" "")

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
