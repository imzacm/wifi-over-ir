cmake_minimum_required(VERSION 3.26)
project(
  wifi-over-ir-client
  VERSION 0.1.0
  DESCRIPTION "WiFi Over IR - Client"
  LANGUAGES C)

# Only do these if this is the main project, and not if it is included through
# add_subdirectory
if(CMAKE_PROJECT_NAME STREQUAL PROJECT_NAME)
  # Optionally set things like CMAKE_CXX_STANDARD,
  # CMAKE_POSITION_INDEPENDENT_CODE here
  set(CMAKE_C_STANDARD 99)

  # Let's nicely support folders in IDEs
  set_property(GLOBAL PROPERTY USE_FOLDERS ON)
endif()

add_executable(woi-client src/main.c)

add_subdirectory("${CMAKE_SOURCE_DIR}/../common" "${CMAKE_BINARY_DIR}/common")
target_link_libraries(woi-client PRIVATE woi_common)
