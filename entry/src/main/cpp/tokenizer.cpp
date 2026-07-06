/**
 * 分词器实现 — P1 占位
 */
#include "tokenizer.h"
#include <hilog/log.h>

#undef LOG_DOMAIN
#undef LOG_TAG
#define LOG_DOMAIN 0x3200
#define LOG_TAG "Tokenizer"

namespace TokenizerLib {

Tokenizer::Tokenizer() : loaded_(false) {
    OH_LOG_INFO(LOG_APP, "[Tokenizer] Tokenizer created (placeholder)");
}

Tokenizer::~Tokenizer() {
    OH_LOG_INFO(LOG_APP, "[Tokenizer] Tokenizer destroyed");
}

bool Tokenizer::LoadVocabulary(const std::string& vocabPath) {
    OH_LOG_INFO(LOG_APP, "[Tokenizer] LoadVocabulary: %{public}s", vocabPath.c_str());
    // P1 阶段不加载实际词表
    loaded_ = false;
    return false;
}

std::vector<int> Tokenizer::Encode(const std::string& text) {
    OH_LOG_INFO(LOG_APP, "[Tokenizer] Encode called for text length: %{public}zu",
                text.length());
    // P1 返回空
    return std::vector<int>();
}

std::string Tokenizer::Decode(const std::vector<int>& tokenIds) {
    OH_LOG_INFO(LOG_APP, "[Tokenizer] Decode called for %{public}zu tokens",
                tokenIds.size());
    // P1 返回空字符串
    return std::string();
}

int Tokenizer::GetVocabSize() const {
    return static_cast<int>(vocab_.size());
}

} // namespace TokenizerLib
