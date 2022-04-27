# CMake Maya finder
#
# Variables that will be defined:
# MAYA_FOUND          Defined if a Maya installation has been detected
# MAYA_EXECUTABLE     Path to Maya's executable
# MAYA_<lib>_FOUND    Defined if <lib> has been found
# MAYA_<lib>_LIBRARY  Path to <lib> library
# MAYA_INCLUDE_DIRS   Path to the devkit's include directories
# MAYA_API_VERSION    Maya version (6-8 digits)
# MAYA_APP_VERSION    Maya app version (4 digits)

# -------------------------------------------------
# Macro for setting up typical plugin properties
# -------------------------------------------------
macro(maya_set_plugin_properties target)
    set_target_properties(${target} PROPERTIES SUFFIX ${MAYA_PLUGIN_SUFFIX})
    set_target_properties(${target} PROPERTIES PREFIX "")

    set(_MAYA_DEFINES REQUIRE_IOSTREAM _BOOL LINUX LINUX_64)
    target_compile_definitions(${target} PRIVATE ${_MAYA_DEFINES})
endmacro()

# -------------------------------------------------
# Set fixed variables
# -------------------------------------------------
set(MAYA_PLUGIN_SUFFIX ".so")

# -------------------------------------------------
# Find various paths
# -------------------------------------------------
find_path(MAYA_LIBRARY_DIR
        libOpenMaya.so
    HINTS
        ${MAYA_LOCATION}
        $ENV{MAYA_LOCATION}
        $ENV{DEVKIT_LOCATION}
    PATH_SUFFIXES
        ../../devkit/lib/
        lib/
    DOC
        "Maya's libraries path"
)

find_path(MAYA_INCLUDE_DIR
        maya/MFn.h
    HINTS
        ${MAYA_LOCATION}
        $ENV{MAYA_LOCATION}
        $ENV{DEVKIT_LOCATION}
    PATH_SUFFIXES
        ../../devkit/include/
        include/
    DOC
        "Maya's headers path"
)
list(APPEND MAYA_INCLUDE_DIRS ${MAYA_INCLUDE_DIR})

find_library(MAYA_LIBRARY
    NAMES
        OpenMaya
    HINTS
        ${MAYA_LOCATION}
        $ENV{MAYA_LOCATION}
        $ENV{MAYA_LOCATION}
        $ENV{DEVKIT_LOCATION}
    PATH_SUFFIXES
        ../../devkit/lib/
        lib/
    DOC
        "OpenMaya library path"
)

# -------------------------------------------------
# Define the Maya::Maya target
# -------------------------------------------------
if (NOT TARGET Maya::Maya)
    add_library(Maya::Maya UNKNOWN IMPORTED)
    set_target_properties(Maya::Maya PROPERTIES
        INTERFACE_COMPILE_DEFINITIONS "REQUIRE_IOSTREAM;_BOOL;LINUX;LINUX_64"
        INTERFACE_INCLUDE_DIRECTORIES "${MAYA_INCLUDE_DIR}"
        IMPORTED_LOCATION "${MAYA_LIBRARY}")

    #set_property(TARGET Maya::Maya APPEND PROPERTY
    #    INTERFACE_COMPILE_OPTIONS $<$<PLATFORM_ID:Linux>:"-fPIC">)
endif()

set(MAYA_LIBS_TO_FIND
    OpenMaya
    OpenMayaAnim
    OpenMayaFX
    OpenMayaRender
    OpenMayaUI
    Image
    Foundation
    IMFbase
    cg
    cgGL
    clew
)

foreach(MAYA_LIB ${MAYA_LIBS_TO_FIND})
    find_library(MAYA_${MAYA_LIB}_LIBRARY
        NAMES
            ${MAYA_LIB}
        HINTS
            "${MAYA_LIBRARY_DIR}"
        DOC
            "Maya's ${MAYA_LIB} library path"
    )

    mark_as_advanced(MAYA_${MAYA_LIB}_LIBRARY)

    if (MAYA_${MAYA_LIB}_LIBRARY)
        add_library(Maya::${MAYA_LIB} UNKNOWN IMPORTED)
        set_target_properties(Maya::${MAYA_LIB} PROPERTIES
            IMPORTED_LOCATION "${MAYA_${MAYA_LIB}_LIBRARY}")
        set_property(TARGET Maya::Maya APPEND PROPERTY
            INTERFACE_LINK_LIBRARIES Maya::${MAYA_LIB})

        list(APPEND MAYA_LIBRARIES ${MAYA_${MAYA_LIB}_LIBRARY})
    endif()

endforeach()

find_program(MAYA_EXECUTABLE
        maya
    HINTS
        "${MAYA_LOCATION}"
        "$ENV{MAYA_LOCATION}"
        "${MAYA_BASE_DIR}"
    PATH_SUFFIXES
        Maya.app/Contents/bin/
        bin/
    DOC
        "Maya's executable path"
)

if(MAYA_INCLUDE_DIRS AND EXISTS "${MAYA_INCLUDE_DIR}/maya/MTypes.h")
    # Tease the MAYA_API_VERSION numbers from the lib headers
    file(STRINGS ${MAYA_INCLUDE_DIR}/maya/MTypes.h TMP REGEX "#define MAYA_API_VERSION.*$")
    string(REGEX MATCHALL "[0-9]+" MAYA_API_VERSION ${TMP})

    # MAYA_APP_VERSION
    file(STRINGS ${MAYA_INCLUDE_DIR}/maya/MTypes.h MAYA_APP_VERSION REGEX "#define MAYA_APP_VERSION.*$")
    if(MAYA_APP_VERSION)
        string(REGEX MATCHALL "[0-9]+" MAYA_APP_VERSION ${MAYA_APP_VERSION})
    else()
        string(SUBSTRING ${MAYA_API_VERSION} "0" "4" MAYA_APP_VERSION)
    endif()
endif()

# Determine the Python version and switch between mayapy and mayapy2.
set(MAYAPY_EXE mayapy)
set(MAYA_PY_VERSION 2)
if(${MAYA_APP_VERSION} STRGREATER_EQUAL "2021")
    set(MAYA_PY_VERSION 3)

    # check to see if we have a mayapy2 executable
    find_program(MAYA_PY_EXECUTABLE2
            mayapy2
        HINTS
            "${MAYA_LOCATION}"
            "$ENV{MAYA_LOCATION}"
        PATH_SUFFIXES
            Maya.app/Contents/bin/
            bin/
        DOC
            "Maya's Python executable path"
    )
    if(NOT BUILD_WITH_PYTHON_3 AND MAYA_PY_EXECUTABLE2)
        set(MAYAPY_EXE mayapy2)
        set(MAYA_PY_VERSION 2)
    endif()
endif()

find_program(MAYA_PY_EXECUTABLE
        ${MAYAPY_EXE}
    HINTS
        "${MAYA_LOCATION}"
        "$ENV{MAYA_LOCATION}"
    PATH_SUFFIXES
        Maya.app/Contents/bin/
        bin/
    DOC
        "Maya's Python executable path"
)

# Log results
message("Maya finder: ================================================")
message("   MAYA_INCLUDE_DIR: ${MAYA_INCLUDE_DIR}")
message("   MAYA_INCLUDE_DIRS: ${MAYA_INCLUDE_DIRS}")
message("   MAYA_LIBRARY_DIR: ${MAYA_LIBRARY_DIR}")
message("   MAYA_LIBRARIES: ${MAYA_LIBRARIES}")
message("   MAYA_API_VERSION: ${MAYA_API_VERSION}")
message("   MAYA_APP_VERSION: ${MAYA_APP_VERSION}")
message("   MAYA_PY_EXECUTABLE: ${MAYA_PY_EXECUTABLE}")
message("=============================================================")

# handle the QUIETLY and REQUIRED arguments and set MAYA_FOUND to TRUE if
# all listed variables are TRUE
include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(Maya
    REQUIRED_VARS
        MAYA_EXECUTABLE
        MAYA_PY_EXECUTABLE
        MAYA_PY_VERSION
        MAYA_INCLUDE_DIRS
        MAYA_LIBRARIES
        MAYA_API_VERSION
        MAYA_APP_VERSION
    VERSION_VAR
        MAYA_APP_VERSION
)
