cmake_minimum_required(VERSION 3.26)
project(
  wifi-over-ir-gateway
  VERSION 0.1.0
  DESCRIPTION "WiFi Over IR - Gateway"
  LANGUAGES C)

set(PROJECT_AUTHOR "Zac McChesney")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../cmake")

# Only do these if this is the main project, and not if it is included through
# add_subdirectory
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  # Optionally set things like CMAKE_CXX_STANDARD,
  # CMAKE_POSITION_INDEPENDENT_CODE here
  set(CMAKE_C_STANDARD 99)

  # Let's nicely support folders in IDEs
  set_property(GLOBAL PROPERTY USE_FOLDERS ON)
endif()

add_executable(woi-gateway src/main.c)

add_subdirectory("${CMAKE_SOURCE_DIR}/../common" "${CMAKE_BINARY_DIR}/common")
target_link_libraries(woi-gateway PRIVATE woi_common)

if(NINTENDO_3DS)
  include(3DS-Tools)

  set(wio_asset_icon "${CMAKE_CURRENT_LIST_DIR}/../assets/icon-48x48.png")
  set(wio_asset_banner_image "${CMAKE_CURRENT_LIST_DIR}/../assets/banner-256x128.png")
  set(wio_asset_banner_audio "${CMAKE_CURRENT_LIST_DIR}/../assets/banner-audio.wav")
  set(wio_asset_gateway_rsf "${CMAKE_CURRENT_LIST_DIR}/../assets/gateway-cia.rsf")

  set(wio_gateway_smdh "${CMAKE_CURRENT_BINARY_DIR}/woi-gateway.smdh")
  set(wio_gateway_3dsx "${CMAKE_CURRENT_BINARY_DIR}/woi-gateway.3dsx")
  set(wio_gateway_cia "${CMAKE_CURRENT_BINARY_DIR}/woi-gateway.cia")
  set(wio_gateway_banner "${CMAKE_CURRENT_BINARY_DIR}/woi-gateway.bnr")

  ctr_generate_smdh(
    OUTPUT "${wio_gateway_smdh}"
    NAME "${CMAKE_PROJECT_NAME}"
    DESCRIPTION "${CMAKE_PROJECT_DESCRIPTION}"
    AUTHOR "${PROJECT_AUTHOR}"
    ICON "${wio_asset_icon}"
  )

  ctr_create_banner(
    OUTPUT "${wio_gateway_banner}"
    IMAGE "${wio_asset_banner_image}"
    AUDIO "${wio_asset_banner_audio}")

  ctr_create_3dsx(woi-gateway
    OUTPUT "${wio_gateway_3dsx}"
    SMDH "${wio_gateway_smdh}")

  ctr_create_cia(woi-gateway
    OUTPUT "${wio_gateway_cia}"
    RSF "${wio_asset_gateway_rsf}"
    BANNER "${wio_gateway_banner}"
    ICON "${wio_gateway_smdh}")
endif()
