/**
 * 文本导入器 — 解析自然语言文本为结构化简历数据
 * P1: 仅定义骨架，不实现具体解析逻辑
 */
import { ResumeData } from '../model/ResumeData';

export class TextImporter {
  /**
   * 解析自然语言文本为结构化简历数据
   * P1: 返回空的 ResumeData
   */
  static parseResumeText(text: string): ResumeData {
    return new ResumeData();
  }

  /**
   * 检查导入引擎是否就绪
   * P1: 永远返回 false
   */
  static isReady(): boolean {
    return false;
  }
}
