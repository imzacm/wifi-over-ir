cmake_minimum_required(VERSION 3.26)
project(
  wifi-over-ir
  VERSION 0.1.0
  DESCRIPTION "WiFi Over IR"
  LANGUAGES C)

set(PROJECT_AUTHOR "Zac McChesney")
set(WOI_ASSETS_DIR "${CMAKE_CURRENT_LIST_DIR}/assets")

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

# Only do these if this is the main project, and not if it is included through
# add_subdirectory
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  # Optionally set things like CMAKE_CXX_STANDARD,
  # CMAKE_POSITION_INDEPENDENT_CODE here
  set(CMAKE_C_STANDARD 99)

  # Let's nicely support folders in IDEs
  set_property(GLOBAL PROPERTY USE_FOLDERS ON)
endif()

add_executable(woi
  src/result.c
  src/main.c)
target_include_directories(woi PRIVATE includes)

if(NINTENDO_3DS)
  add_library(woi-platform-3ds OBJECT
    src/platform/3ds-init.c)
  target_include_directories(woi-platform-3ds PRIVATE includes)

  target_link_libraries(woi PRIVATE woi-platform-3ds)
elseif(DOS)
  add_library(woi-platform-dos OBJECT
    src/platform/dos-init.c
    src/platform/dos-hornet.c)
  target_include_directories(woi-platform-dos PRIVATE includes)

  target_link_libraries(woi PRIVATE woi-platform-dos)
endif()

if(NINTENDO_3DS)
  include(3DS-Tools)

  set(WOI_ASSET_ICON "${WOI_ASSETS_DIR}/icon-48x48.png")
  set(WOI_ASSET_BANNER_IMAGE "${WOI_ASSETS_DIR}/banner-256x128.png")
  set(WOI_ASSET_BANNER_AUDIO "${WOI_ASSETS_DIR}/banner-audio.wav")

  set(WOI_SMDH "${CMAKE_CURRENT_BINARY_DIR}/woi-gateway.smdh")
  set(WOI_3dsx "${CMAKE_CURRENT_BINARY_DIR}/woi-gateway.3dsx")
  set(WOI_CIA "${CMAKE_CURRENT_BINARY_DIR}/woi-gateway.cia")
  set(WOI_BANNER "${CMAKE_CURRENT_BINARY_DIR}/woi-gateway.bnr")

  ctr_generate_smdh(
    OUTPUT "${WOI_SMDH}"
    NAME "${CMAKE_PROJECT_NAME}"
    DESCRIPTION "${CMAKE_PROJECT_DESCRIPTION}"
    AUTHOR "${PROJECT_AUTHOR}"
    ICON "${WOI_ASSET_ICON}"
  )

  ctr_create_banner(
    OUTPUT "${WOI_BANNER}"
    IMAGE "${WOI_ASSET_BANNER_IMAGE}"
    AUDIO "${WOI_ASSET_BANNER_AUDIO}")

  ctr_create_3dsx(woi
    OUTPUT "${WOI_3dsx}"
    SMDH "${WOI_SMDH}")

  ctr_create_cia(woi
    OUTPUT "${WOI_CIA}"
    BANNER "${WOI_BANNER}"
    ICON "${WOI_SMDH}"
    RSF_TITLE "${CMAKE_PROJECT_NAME}"
    RSF_PRODUCT_CODE "CTR-P-CWOI"
    RSF_RSF_UNIQUE_ID "0xC2C003")
endif()
