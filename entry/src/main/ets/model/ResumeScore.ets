/**
 * 简历评分模型 — AI 评分结果与改进建议
 */

// ==================== 评分维度 ====================
export class ScoreDimension {
  name: string = '';
  score: number = 0;
  maxScore: number = 100;
  weight: number = 0;
  suggestions: string[] = [];
}

// ==================== 关键字分析 ====================
export class KeywordAnalysis {
  matched: string[] = [];
  missing: string[] = [];
  totalRequired: number = 0;
  matchRate: number = 0;
}

// ==================== AI改进建议 ====================
export class AiSuggestion {
  id: string = '';
  category: string = '';
  priority: number = 0; // 1=高, 2=中, 3=低
  title: string = '';
  description: string = '';
  beforeExample: string = '';
  afterExample: string = '';
}

// ==================== 评分结果 ====================
export class ResumeScoreResult {
  overall: number = 0;
  dimensions: ScoreDimension[] = [];
  keywordAnalysis: KeywordAnalysis = new KeywordAnalysis();
  aiSuggestions: AiSuggestion[] = [];
  scoredAt: string = '';
}

// ==================== 评分工具类 ====================
export class ScoreHelper {
  static getGrade(score: number): string {
    if (score >= 90) {
      return '优秀';
    }
    if (score >= 80) {
      return '良好';
    }
    if (score >= 60) {
      return '及格';
    }
    return '待改进';
  }

  static getGradeColor(score: number): string {
    if (score >= 90) {
      return '#059669';
    }
    if (score >= 80) {
      return '#1677FF';
    }
    if (score >= 60) {
      return '#FF9500';
    }
    return '#FF3B30';
  }

  static getDefaultDimensions(): ScoreDimension[] {
    const completeness: ScoreDimension = {
      name: '完整度',
      score: 0,
      maxScore: 100,
      weight: 30,
      suggestions: []
    };
    const layout: ScoreDimension = {
      name: '排版布局',
      score: 0,
      maxScore: 100,
      weight: 20,
      suggestions: []
    };
    const content: ScoreDimension = {
      name: '内容质量',
      score: 0,
      maxScore: 100,
      weight: 30,
      suggestions: []
    };
    const keywords: ScoreDimension = {
      name: '关键词匹配',
      score: 0,
      maxScore: 100,
      weight: 20,
      suggestions: []
    };
    return [completeness, layout, content, keywords];
  }
}
