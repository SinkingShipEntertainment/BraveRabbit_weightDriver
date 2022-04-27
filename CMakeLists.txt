cmake_minimum_required(VERSION 3.1)
project(brWeightDriver)

set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)

add_subdirectory(source)

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/modules/weightDriver/icons DESTINATION ./weightDriver)
install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/modules/weightDriver/scripts DESTINATION ./weightDriver)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/weightDriver.mod DESTINATION .)
