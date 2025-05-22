cmake_policy(SET CMP0048 NEW)
project(
  ${SKBUILD_PROJECT_NAME}
  VERSION ${SKBUILD_PROJECT_VERSION}
  LANGUAGES CXX)

cmake_minimum_required(VERSION 3.15...3.27)

option(BUILD_PYTHON_BINDING "Build Python Binding" off)


set(CMAKE_POSITION_INDEPENDENT_CODE ON)

set(CMAKE_CXX_STANDARD 17)

set(BOOSTER_INSTALL_PATH "$ENV{HOME}/library/booster" CACHE PATH "")
message("Booster INSTALL path: ${BOOSTER_INSTALL_PATH}")

set(BOOSTER_SDK_LIBS 
	${BOOSTER_INSTALL_PATH}/lib/libbooster_robotics_sdk.a
	${BOOSTER_INSTALL_PATH}/lib/libfastrtps.so
	${BOOSTER_INSTALL_PATH}/lib/libfastcdr.so
	${BOOSTER_INSTALL_PATH}/lib/libfoonathan_memory-0.7.3.a
)

# link_libraries(booster_robotics_sdk.a fastrtps fastcdr libfoonathan_memory-0.7.3.a)
nclude_directories(${BOOSTER_INSTALL_PATH}/include)

add_executable(b1_loco_example_client example/high_level/b1_loco_example_client.cpp)
target_link_libraries(b1_loco_example_client PRIVATE ${BOOSTER_SDK_LIBS})

add_executable(b1_arm_sdk_example_client example/high_level/b1_arm_sdk_example.cpp)
target_link_libraries(b1_arm_sdk_example_client PRIVATE ${BOOSTER_SDK_LIBS})

add_executable(b1_7dof_arm_sdk_example_client example/high_level/b1_7dof_arm_sdk_example.cpp)
target_link_libraries(b1_7dof_arm_sdk_example_client PRIVATE ${BOOSTER_SDK_LIBS})

add_executable(b1_low_level_publisher example/low_level/low_level_publisher.cpp)
target_link_libraries(b1_low_level_publisher PRIVATE ${BOOSTER_SDK_LIBS})

add_executable(b1_low_level_subscriber example/low_level/low_level_subscriber.cpp)
target_link_libraries(b1_low_level_subscriber PRIVATE ${BOOSTER_SDK_LIBS})

add_executable(low_level_hand_data_subscriber example/low_level/low_level_hand_data_subscriber.cpp)
target_link_libraries(low_level_hand_data_subscriber PRIVATE ${BOOSTER_SDK_LIBS})

add_executable(b1_low_sdk_example example/low_level/b1_low_sdk_example.cpp)
target_link_libraries(b1_low_sdk_example PRIVATE ${BOOSTER_SDK_LIBS})

add_executable(b1_7dof_arm_low_sdk_example example/low_level/b1_7dof_arm_low_sdk_example.cpp)
target_link_libraries(b1_7dof_arm_low_sdk_example PRIVATE ${BOOSTER_SDK_LIBS})

add_executable(odometer_example example/low_level/odometer_example.cpp)
target_link_libraries(odometer_example PRIVATE ${BOOSTER_SDK_LIBS})

# include_directories(BEFORE $(PROJECT_SOURCE_DIR)/include)


if(BUILD_PYTHON_BINDING)
    find_package(Python3 REQUIRED COMPONENTS Interpreter Development.Module)
    message(STATUS "Python3 executable: ${Python3_EXECUTABLE}")

    execute_process(
        COMMAND ${Python3_EXECUTABLE} -c "import sysconfig; print(sysconfig.get_paths()['purelib'])"
        OUTPUT_VARIABLE PYTHON_SITE_PACKAGES
        OUTPUT_STRIP_TRAILING_WHITESPACE
    )
	
	find_package(pybind11 CONFIG REQUIRED)
	message(${pybind11_INCLUDE_DIRS})
	
    include_directories(${Python3_INCLUDE_DIRS} ${pybind11_INCLUDE_DIRS})

    python3_add_library(booster_robotics_sdk_python MODULE python/binding.cpp WITH_SOABI)

    # --- ADD THESE RPATH LINES ---
    # Define the RPATH for the installed library
    # $ORIGIN means "look in the same directory as the module itself"
    # ${BOOSTER_INSTALL_PATH}/lib is where your libfastrtps.so will be installed
    set(CMAKE_INSTALL_RPATH "$ORIGIN;${BOOSTER_INSTALL_PATH}/lib")
    set_property(TARGET booster_robotics_sdk_python PROPERTY INSTALL_RPATH "${CMAKE_INSTALL_RPATH}")
    set_property(TARGET booster_robotics_sdk_python PROPERTY BUILD_RPATH "${CMAKE_INSTALL_RPATH}") # Also set for the build directory
    set_property(TARGET booster_robotics_sdk_python PROPERTY BUILD_WITH_INSTALL_RPATH TRUE) # Use the install RPATH even in the build tree

    # This is important to ensure RPATH is actually used by the linker
    set_property(TARGET booster_robotics_sdk_python PROPERTY INSTALL_RPATH_USE_LINK_PATH TRUE)
    # --- END RPATH LINES ---
    
    target_compile_definitions(booster_robotics_sdk_python PRIVATE VERSION_INFO=${PROJECT_VERSION})
    
    target_link_libraries(booster_robotics_sdk_python PRIVATE ${BOOSTER_SDK_LIBS})

    find_program(PYBIND11_STUBGEN_EXECUTABLE pybind11-stubgen)
    if(NOT PYBIND11_STUBGEN_EXECUTABLE)
        message(FATAL_ERROR "pybind11-stubgen not found")
    endif()

    add_custom_command(
        TARGET booster_robotics_sdk_python
        POST_BUILD
        COMMAND PYTHONPATH=${CMAKE_SOURCE_DIR}/build:/${PYTHONPATH} pybind11-stubgen -o ${CMAKE_SOURCE_DIR}/build booster_robotics_sdk_python
    )

    install(TARGETS booster_robotics_sdk_python LIBRARY DESTINATION ${PYTHON_SITE_PACKAGES})
    install(FILES ${CMAKE_SOURCE_DIR}/build/booster_robotics_sdk_python.pyi DESTINATION ${PYTHON_SITE_PACKAGES})    
    
    message("Python3 site-packages: ${PYTHON_SITE_PACKAGES}")
endif()

