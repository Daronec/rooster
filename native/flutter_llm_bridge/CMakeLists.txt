cmake_minimum_required(VERSION 3.22.1)

project(llm_bridge)

# C++ стандарт
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Исходные файлы bridge
set(BRIDGE_SOURCES
    llm_bridge.cpp
    llm_bridge.h
)

# llama.cpp
set(LLAMA_CPP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../llama_cpp/llama.cpp")

if(EXISTS "${LLAMA_CPP_DIR}")
    # Отключаем llamafile ГЛОБАЛЬНО для всей сборки llama.cpp
    # Это решает проблему с NEON интринсиками на armeabi-v7a
    set(GGML_LLAMAFILE OFF CACHE BOOL "Disable llamafile optimizations" FORCE)
    
    # Включаем llama.cpp
    add_subdirectory(${LLAMA_CPP_DIR} llama_cpp_build)
    
    # Собираем bridge
    add_library(llm_bridge SHARED ${BRIDGE_SOURCES})
    
    # Добавляем include директории
    target_include_directories(llm_bridge PRIVATE
        ${LLAMA_CPP_DIR}/include
        ${LLAMA_CPP_DIR}/ggml/include
    )
    
    # Отключаем оптимизации под мобильные CPU
    target_compile_options(llm_bridge PRIVATE
        -DLLAMA_NATIVE=OFF
        -DLLAMA_AVX=OFF
        -DLLAMA_FMA=OFF
        -DLLAMA_F16C=OFF
    )
    
    # Android-specific
    if(ANDROID)
        # Связываем с llama и Android библиотеками
        target_link_libraries(llm_bridge PRIVATE
            llama
            android
            log
        )
    else()
        target_link_libraries(llm_bridge PRIVATE llama)
    endif()
    
    # Общие настройки
    target_compile_options(llm_bridge PRIVATE
        -fexceptions
        -frtti
    )
    
    message(STATUS "Building with llama.cpp (llamafile disabled)")
else()
    # Fallback: собираем без llama.cpp (STUB mode)
    add_library(llm_bridge SHARED ${BRIDGE_SOURCES})
    message(WARNING "llama.cpp not found, building STUB mode")
endif()
