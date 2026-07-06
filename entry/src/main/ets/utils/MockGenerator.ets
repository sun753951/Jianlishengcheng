/**
 * Mock 生成器 — 模拟 AI 简历生成流程，包含加载动画与进度回调
 */
import { ResumeData, GenerateResult, ResumeGenerateStatus } from '../model/ResumeData';

// 进度回调类型
export type ProgressCallback = (progress: number, message: string) => void;

const STEP_MESSAGES: string[] = [
  '正在分析您的个人信息...',
  '正在优化教育经历描述...',
  '正在提炼工作经历亮点...',
  '正在整理项目经验...',
  '正在匹配技能关键词...',
  '正在生成排版布局...',
  '正在润色语言表达...',
  '正在最终检查...'
];

export class MockGenerator {
  /**
   * 模拟 AI 生成简历
   * @param inputData 用户输入的原始数据
   * @param onProgress 进度回调
   * @returns 生成后的简历数据
   */
  static async generate(
    inputData: ResumeData,
    onProgress: ProgressCallback
  ): Promise<ResumeData> {
    const totalSteps: number = STEP_MESSAGES.length;
    const stepDuration: number = 600; // 每步600ms，总计约4.8秒

    for (let i: number = 0; i < totalSteps; i++) {
      const progress: number = Math.floor(((i + 1) / totalSteps) * 100);
      onProgress(progress, STEP_MESSAGES[i]);

      // 模拟异步处理
      await MockGenerator.delay(stepDuration);
    }

    // 返回增强后的简历数据
    return MockGenerator.enhanceResume(inputData);
  }

  /**
   * 模拟增强简历内容
   */
  static enhanceResume(inputData: ResumeData): ResumeData {
    // 拷贝输入数据
    const result: ResumeData = {
      id: 'gen-' + Date.now().toString(),
      createdAt: new Date().toISOString().slice(0, 10),
      updatedAt: new Date().toISOString().slice(0, 10),
      templateType: inputData.templateType,
      colorScheme: inputData.colorScheme,
      personalInfo: {
        name: inputData.personalInfo.name,
        gender: inputData.personalInfo.gender,
        birthDate: inputData.personalInfo.birthDate,
        phone: inputData.personalInfo.phone,
        email: inputData.personalInfo.email,
        address: inputData.personalInfo.address,
        title: inputData.personalInfo.title,
        summary: MockGenerator.enhanceSummary(inputData.personalInfo.summary),
        avatarUri: inputData.personalInfo.avatarUri,
        website: inputData.personalInfo.website,
        linkedIn: inputData.personalInfo.linkedIn,
        github: inputData.personalInfo.github
      },
      education: [...inputData.education],
      workExperience: [...inputData.workExperience],
      projects: [...inputData.projects],
      skills: [...inputData.skills],
      languages: [...inputData.languages],
      certificates: [...inputData.certificates],
      customSections: [...inputData.customSections]
    };
    return result;
  }

  /**
   * 增强个人总结
   */
  static enhanceSummary(original: string): string {
    if (original.length < 50) {
      return original + ' 具备扎实的技术基础和丰富的项目经验，注重代码质量和团队协作。';
    }
    return original;
  }

  /**
   * 延迟函数
   */
  static delay(ms: number): Promise<void> {
    return new Promise<void>((resolve: (value: void) => void) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }

  /**
   * 获取生成状态消息
   */
  static getStatusMessage(status: ResumeGenerateStatus): string {
    switch (status) {
      case ResumeGenerateStatus.IDLE:
        return '等待生成';
      case ResumeGenerateStatus.GENERATING:
        return '正在生成...';
      case ResumeGenerateStatus.SUCCESS:
        return '生成成功';
      case ResumeGenerateStatus.FAILED:
        return '生成失败';
      default:
        return '';
    }
  }
}
