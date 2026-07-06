/**
 * NAPI 主入口 — 简历生成模块初始化
 */
#include <napi/native_api.h>
#include <hilog/log.h>
#include "resume_generator.h"

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200
#define LOG_TAG "ResumeNAPI"

EXTERN_C_START

/**
 * 生成简历的 NAPI 接口（占位）
 */
static napi_value GenerateResume(napi_env env, napi_callback_info info) {
    OH_LOG_INFO(LOG_APP, "[ResumeNAPI] GenerateResume called (placeholder)");
    napi_value result;
    napi_create_string_utf8(env, "P1 placeholder - AI engine not loaded", NAPI_AUTO_LENGTH, &result);
    return result;
}

/**
 * 获取引擎状态的 NAPI 接口
 */
static napi_value GetEngineStatus(napi_env env, napi_callback_info info) {
    napi_value result;
    napi_create_string_utf8(env, "not_available", NAPI_AUTO_LENGTH, &result);
    return result;
}

/**
 * 模块初始化
 */
static napi_value Init(napi_env env, napi_value exports) {
    OH_LOG_INFO(LOG_APP, "[ResumeNAPI] Module initializing...");

    napi_property_descriptor desc[] = {
        {"generateResume", nullptr, GenerateResume, nullptr, nullptr, nullptr, napi_default, nullptr},
        {"getEngineStatus", nullptr, GetEngineStatus, nullptr, nullptr, nullptr, napi_default, nullptr}
    };

    napi_define_properties(env, exports, sizeof(desc) / sizeof(desc[0]), desc);
    OH_LOG_INFO(LOG_APP, "[ResumeNAPI] Module initialized successfully");
    return exports;
}

EXTERN_C_END

// 注册模块
static napi_module resumeModule = {
    .nm_version = 1,
    .nm_flags = 0,
    .nm_filename = nullptr,
    .nm_register_func = Init,
    .nm_modname = "resume_napi",
    .nm_priv = nullptr,
    .reserved = {0},
};

extern "C" __attribute__((constructor)) void RegisterResumeNapiModule(void) {
    napi_module_register(&resumeModule);
}
