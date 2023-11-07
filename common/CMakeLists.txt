set(woi_common_src "")

if(NINTENDO_3DS)
    file(GLOB woi_common_3ds_src
        "${CMAKE_CURRENT_SOURCE_DIR}/src/hal/3ds/*")
    list(APPEND woi_common_src ${woi_common_3ds_src})
elseif(DOS)
    file(GLOB woi_common_dos_src
        "${CMAKE_CURRENT_SOURCE_DIR}/src/hal/dos/*")
    list(APPEND woi_common_src ${woi_common_dos_src})
endif()

add_library(woi_common STATIC ${woi_common_src})
target_include_directories(woi_common PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/includes")
