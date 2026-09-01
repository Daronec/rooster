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

# llama.cpp (если существует)
set(LLAMA_CPP_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../llama_cpp/llama.cpp")

if(EXISTS "${LLAMA_CPP_DIR}")
    # Включаем llama.cpp как поддиректорию
    add_subdirectory(${LLAMA_CPP_DIR} llama_cpp_build EXCLUDE_FROM_ALL)
    
    # Находим llama library
    find_library(LLAMA_LIBRARY llama)
    
    if(LLAMA_LIBRARY)
        # Собираем с llama.cpp
        add_library(llm_bridge SHARED ${BRIDGE_SOURCES})
        
        target_include_directories(llm_bridge PRIVATE
            ${LLAMA_CPP_DIR}/include
            ${LLAMA_CPP_DIR}/ggml/include
        )
        
        target_link_libraries(llm_bridge PRIVATE ${LLAMA_LIBRARY})
        
        # Отключаем оптимизации под мобильные CPU
        target_compile_options(llm_bridge PRIVATE
            -DLLAMA_NATIVE=OFF
            -DLLAMA_AVX=OFF
            -DLLAMA_FMA=OFF
            -DLLAMA_F16C=OFF
        )
    else()
        # Fallback: собираем без llama.cpp (STUB mode)
        add_library(llm_bridge SHARED ${BRIDGE_SOURCES})
    endif()
else()
    # Fallback: собираем без llama.cpp (STUB mode)
    add_library(llm_bridge SHARED ${BRIDGE_SOURCES})
endif()

# Общие настройки
target_compile_options(llm_bridge PRIVATE
    -fexceptions
    -frtti
)

# Android-specific
if(ANDROID)
    target_link_libraries(llm_bridge
        android
        log
    )
endif()
