/**
 * 简历生成器实现 — P1 占位实现
 */
#include "resume_generator.h"
#include <hilog/log.h>

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200
#define LOG_TAG "ResumeGen"

namespace ResumeGenerator {

ResumeGeneratorEngine::ResumeGeneratorEngine()
    : initialized_(false), version_("1.0.0-P1-placeholder") {
    OH_LOG_INFO(LOG_APP, "[ResumeGen] Engine constructed");
}

ResumeGeneratorEngine::~ResumeGeneratorEngine() {
    OH_LOG_INFO(LOG_APP, "[ResumeGen] Engine destroyed");
}

bool ResumeGeneratorEngine::Initialize(const std::string& modelPath) {
    OH_LOG_INFO(LOG_APP, "[ResumeGen] Initialize called with model: %{public}s",
                modelPath.c_str());
    // P1 阶段：不加载实际模型
    initialized_ = false;
    OH_LOG_INFO(LOG_APP, "[ResumeGen] P1 placeholder - model not loaded");
    return false;
}

GenerateResult ResumeGeneratorEngine::Generate(const ResumeData& input) {
    OH_LOG_INFO(LOG_APP, "[ResumeGen] Generate called for: %{public}s",
                input.personalInfo.name.c_str());

    GenerateResult result;
    result.success = false;
    result.message = "P1 placeholder - AI engine not yet available";
    result.enhancedText = input.personalInfo.summary;
    return result;
}

bool ResumeGeneratorEngine::IsReady() const {
    return initialized_;
}

std::string ResumeGeneratorEngine::GetVersion() const {
    return version_;
}

} // namespace ResumeGenerator
