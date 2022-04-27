
find_package(Maya REQUIRED)

file(GLOB_RECURSE WEIGHTDRIVER_HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/*.h")
file(GLOB_RECURSE WEIGHTDRIVER_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")

add_library(${PROJECT_NAME} SHARED ${WEIGHTDRIVER_HEADERS} ${WEIGHTDRIVER_SOURCES})

# Link to Maya
target_link_libraries(${PROJECT_NAME} PRIVATE Maya::Maya)

# Includes Maya and current directory
target_include_directories(${PROJECT_NAME} PRIVATE Maya::Maya)
target_include_directories(${PROJECT_NAME} PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")

maya_set_plugin_properties(${PROJECT_NAME})

install(TARGETS ${PROJECT_NAME} LIBRARY DESTINATION weightDriver/plug-ins)
