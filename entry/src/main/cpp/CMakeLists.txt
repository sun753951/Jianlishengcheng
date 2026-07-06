# NAPI 简历生成模块 CMake 配置
cmake_minimum_required(VERSION 3.5.0)
project(resume_napi)

# 添加 NAPI 原生库
add_library(resume_napi SHARED
    napi_init.cpp
    resume_generator.cpp
    onnx_session.cpp
    tokenizer.cpp
)

# 链接 NAPI 原生 SDK
target_link_libraries(resume_napi PUBLIC
    libace_napi.z.so
    libhilog_ndk.z.so
)
