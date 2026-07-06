/**
 * 简历生成器头文件 — 定义简历AI生成核心接口
 */
#ifndef RESUME_GENERATOR_H
#define RESUME_GENERATOR_H

#include <string>
#include <vector>
#include <map>

namespace ResumeGenerator {

// 简历结构化数据
struct PersonalInfo {
    std::string name;
    std::string email;
    std::string phone;
    std::string summary;
};

struct WorkExperience {
    std::string company;
    std::string position;
    std::string startDate;
    std::string endDate;
    std::string description;
};

struct ResumeData {
    PersonalInfo personalInfo;
    std::vector<WorkExperience> workExperience;
    std::vector<std::string> skills;
};

// 生成结果
struct GenerateResult {
    bool success;
    std::string message;
    std::string enhancedText;
};

class ResumeGeneratorEngine {
public:
    ResumeGeneratorEngine();
    ~ResumeGeneratorEngine();

    // 初始化引擎
    bool Initialize(const std::string& modelPath);

    // 生成/优化简历
    GenerateResult Generate(const ResumeData& input);

    // 获取引擎状态
    bool IsReady() const;
    std::string GetVersion() const;

private:
    bool initialized_;
    std::string version_;
};

} // namespace ResumeGenerator

#endif // RESUME_GENERATOR_H
