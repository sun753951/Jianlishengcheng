/**
 * 分词器头文件 — P1 占位
 */
#ifndef TOKENIZER_H
#define TOKENIZER_H

#include <string>
#include <vector>
#include <map>

namespace TokenizerLib {

struct Token {
    int id;
    std::string text;
};

class Tokenizer {
public:
    Tokenizer();
    ~Tokenizer();

    // 加载词表
    bool LoadVocabulary(const std::string& vocabPath);

    // 编码文本为 token IDs
    std::vector<int> Encode(const std::string& text);

    // 解码 token IDs 为文本
    std::string Decode(const std::vector<int>& tokenIds);

    // 获取词表大小
    int GetVocabSize() const;

private:
    std::map<std::string, int> vocab_;
    std::vector<std::string> idToToken_;
    bool loaded_;
};

} // namespace TokenizerLib

#endif // TOKENIZER_H
