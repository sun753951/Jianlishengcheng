/**
 * resume_napi 模块 TypeScript 声明文件
 */

/**
 * 简历生成结果
 */
interface GenerateResult {
  /** 是否成功 */
  success: boolean;
  /** 结果消息 */
  message: string;
  /** 增强后的文本内容 */
  enhancedText: string;
}

/**
 * 简历数据输入
 */
interface ResumeInputData {
  personalInfo: {
    name: string;
    email: string;
    phone: string;
    summary: string;
  };
  workExperience: Array<{
    company: string;
    position: string;
    startDate: string;
    endDate: string;
    description: string;
  }>;
  skills: string[];
}

/**
 * 生成简历
 * @param inputData 输入简历数据（JSON字符串）
 * @returns 生成结果（JSON字符串）
 */
export function generateResume(inputData: string): string;

/**
 * 获取引擎状态
 * @returns 状态字符串: "ready" | "not_available" | "error"
 */
export function getEngineStatus(): string;
