include(FetchContent)

FetchContent_Declare(log_h_git
  GIT_REPOSITORY https://github.com/thlorenz/log.h.git
  GIT_TAG 0.3.0)
FetchContent_MakeAvailable(log_h_git)
file(MAKE_DIRECTORY "${log_h_git_SOURCE_DIR}/includes")
configure_file("${log_h_git_SOURCE_DIR}/log.h" "${log_h_git_SOURCE_DIR}/includes/log.h" COPYONLY)

if(NOT TARGET log_h)
  add_library(log_h INTERFACE)
  target_include_directories(log_h INTERFACE "${log_h_git_SOURCE_DIR}/includes")
endif()
