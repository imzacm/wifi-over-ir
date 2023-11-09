add_library(woi_protocol OBJECT
    src/placeholder.c)
target_include_directories(woi_protocol PUBLIC includes)

# find_package(log_h)
# target_link_libraries(woi_protocol PRIVATE log_h)
