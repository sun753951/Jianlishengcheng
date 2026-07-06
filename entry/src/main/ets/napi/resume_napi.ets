/**
 * resume_napi 模块 ArkTS 封装 — 对 C++ NAPI 模块的 TypeScript 包装
 * P1 阶段：纯 ArkTS 占位实现，未来接入原生 .so 模块
 */
import { ResumeData, GenerateResult, ResumeGenerateStatus } from '../model/ResumeData';

/**
 * 原生模块返回类型
 */
class NativeGenerateResult {
  success: boolean = false;
  message: string = '';
  enhancedText: string = '';
}

export class ResumeNapi {
  /**
   * 获取引擎状态（P1始终返回 not_available）
   */
  getEngineStatus(): string {
    return 'not_available';
  }

  /**
   * 调用原生 AI 引擎生成简历（P1占位）
   * @param resumeData 简历数据
   * @returns 生成结果
   */
  generate(resumeData: ResumeData): GenerateResult {
    const result: GenerateResult = {
      status: ResumeGenerateStatus.FAILED,
      message: '原生AI引擎尚未部署（P1占位）',
      resumeId: '',
      progress: 0,
      errorCode: 0
    };
    return result;
  }

  /**
   * 检查原生引擎是否可用
   */
  isAvailable(): boolean {
    return false;
  }

  /**
   * 获取引擎版本
   */
  getVersion(): string {
    return '1.0.0-P1-placeholder';
  }
}
