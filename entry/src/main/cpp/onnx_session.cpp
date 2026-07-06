/**
 * ONNX 推理会话实现 — P1 占位
 */
#include "onnx_session.h"
#include <hilog/log.h>

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200
#define LOG_TAG "OnnxSession"

namespace OnnxInference {

OnnxSession::OnnxSession() : loaded_(false) {
    OH_LOG_INFO(LOG_APP, "[OnnxSession] Session created (placeholder)");
}

OnnxSession::~OnnxSession() {
    Release();
}

bool OnnxSession::LoadModel(const std::string& modelPath) {
    OH_LOG_INFO(LOG_APP, "[OnnxSession] LoadModel: %{public}s", modelPath.c_str());
    // P1 阶段不实际加载 ONNX 模型
    loaded_ = false;
    return false;
}

bool OnnxSession::Run(const std::vector<TensorData>& inputs,
                      std::vector<TensorData>& outputs) {
    OH_LOG_INFO(LOG_APP, "[OnnxSession] Run called with %{public}zu inputs", inputs.size());
    // P1 阶段不执行推理
    return false;
}

void OnnxSession::Release() {
    loaded_ = false;
    OH_LOG_INFO(LOG_APP, "[OnnxSession] Resources released");
}

bool OnnxSession::IsLoaded() const {
    return loaded_;
}

} // namespace OnnxInference
