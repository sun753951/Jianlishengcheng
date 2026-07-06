/**
 * TextToResumeParser — 「文本→简历」转换接口
 * 提供抽象基类 + Mock 占位实现 + 工厂方法，供未来接入真实解析器
 */
import { ResumeData } from '../model/ResumeData';

// 解析结果类
export class TextToResumeResult {
  success: boolean = false;
  message: string = '';
  resume: ResumeData = new ResumeData();
}

// 解析器抽象基类
export abstract class TextToResumeParser {
  abstract parse(rawText: string): TextToResumeResult;
}

// Mock 占位实现
export class MockTextToResumeParser extends TextToResumeParser {
  parse(rawText: string): TextToResumeResult {
    const result: TextToResumeResult = new TextToResumeResult();
    result.success = false;
    result.message = '文本解析功能开发中，敬请期待';
    return result;
  }
}

// 模块级单例
let parserInstance: TextToResumeParser | null = null;

// 获取解析器实例（默认 Mock）
export function getTextToResumeParser(): TextToResumeParser {
  if (parserInstance === null) {
    parserInstance = new MockTextToResumeParser();
  }
  return parserInstance;
}

// 切换实现（未来真实解析器接入用）
export function setTextToResumeParser(parser: TextToResumeParser): void {
  parserInstance = parser;
}
