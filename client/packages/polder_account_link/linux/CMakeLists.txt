cmake_minimum_required(VERSION 3.10)

set(PROJECT_NAME "polder_account_link")
project(${PROJECT_NAME} LANGUAGES CXX)

set(PLUGIN_NAME "polder_account_link_plugin")

find_package(PkgConfig REQUIRED)
pkg_check_modules(LIBSECRET REQUIRED IMPORTED_TARGET libsecret-1>=0.18.4)

add_library(${PLUGIN_NAME} SHARED
  "polder_account_link_plugin.cc"
)

apply_standard_settings(${PLUGIN_NAME})

set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)

target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::LIBSECRET)

set(polder_account_link_bundled_libraries
  ""
  PARENT_SCOPE
)
