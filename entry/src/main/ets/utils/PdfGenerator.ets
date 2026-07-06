/**
 * PDF 生成器 — P1 占位，预留 PDF 导出接口
 */
import { ResumeData } from '../model/ResumeData';
import { TemplateConfig } from '../model/TemplateConfig';

export class PdfGenerateResult {
  success: boolean = false;
  filePath: string = '';
  errorMessage: string = '';
}

export class PdfGenerator {
  /**
   * 导出简历为 PDF（P1 占位实现）
   * @param resumeData 简历数据
   * @param templateConfig 模板配置
   * @returns 生成结果
   */
  static async exportToPdf(
    resumeData: ResumeData,
    templateConfig: TemplateConfig
  ): Promise<PdfGenerateResult> {
    // P1 阶段：返回占位结果，提示功能开发中
    const result: PdfGenerateResult = {
      success: false,
      filePath: '',
      errorMessage: 'PDF导出功能开发中，敬请期待'
    };
    return result;
  }

  /**
   * 检查 PDF 模块是否可用
   */
  static isAvailable(): boolean {
    return false; // P1 阶段不可用
  }
}
