import { ResumeTemplateType } from '../model/ResumeModels';

// 模板视觉主题接口
export interface TemplateVisualTheme {
  headerBg: string;
  headerText: string;
  headerSubText: string;
  headerMutedText: string;
  nameColor: string;
  positionColor: string;
  contactColor: string;
  accentColor: string;
  softColor: string;
  cardBg: string;
  cardBorder: string;
  sectionTitleColor: string;
  sectionContentColor: string;
  sectionBg: string;
  sectionBorder: string;
  skillTagBg: string;
  skillTagText: string;
  skillTagBorder: string;
  dividerColor: string;
  bodyBg: string;
  outerBorder: string;
  summaryColor: string;
  photoSize: number;
  photoRadius: number;
  nameFontSize: number;
  bodyPaddingV: number;
  bodyPaddingH: number;
  cardRadius: number;
  sectionRadius: number;
  hasPhoto: boolean;
}

// STANDARD（标准）— Teal蓝绿调，经典上下结构
const STANDARD_THEME: TemplateVisualTheme = {
  headerBg: '#FFFFFF',
  headerText: '#111827',
  headerSubText: '#374151',
  headerMutedText: '#6B7280',
  nameColor: '#111827',
  positionColor: '#374151',
  contactColor: '#6B7280',
  accentColor: '#0F766E',
  softColor: '#CCFBF1',
  cardBg: '#FFFFFF',
  cardBorder: '#CBD5E1',
  sectionTitleColor: '#111827',
  sectionContentColor: '#1F2937',
  sectionBg: '#FFFFFF',
  sectionBorder: '#FFFFFF',
  skillTagBg: '#CCFBF1',
  skillTagText: '#0F766E',
  skillTagBorder: '#C7D2FE',
  dividerColor: '#D1D5DB',
  bodyBg: '#FFFFFF',
  outerBorder: '#CBD5E1',
  summaryColor: '#374151',
  photoSize: 72,
  photoRadius: 6,
  nameFontSize: 28,
  bodyPaddingV: 24,
  bodyPaddingH: 28,
  cardRadius: 16,
  sectionRadius: 12,
  hasPhoto: true
};

// TECHNICAL（技术）— 深蓝header + 深色技能胶囊
const TECHNICAL_THEME: TemplateVisualTheme = {
  headerBg: '#1E3A8A',
  headerText: '#FFFFFF',
  headerSubText: '#BFDBFE',
  headerMutedText: '#93C5FD',
  nameColor: '#FFFFFF',
  positionColor: '#BFDBFE',
  contactColor: '#93C5FD',
  accentColor: '#1E3A8A',
  softColor: '#DBEAFE',
  cardBg: '#FFFFFF',
  cardBorder: '#A5B4FC',
  sectionTitleColor: '#1E3A8A',
  sectionContentColor: '#1F2937',
  sectionBg: '#F8FAFF',
  sectionBorder: '#C7D2FE',
  skillTagBg: 'rgba(255,255,255,0.15)',
  skillTagText: '#DBEAFE',
  skillTagBorder: 'rgba(255,255,255,0.2)',
  dividerColor: '#D1D5DB',
  bodyBg: '#FFFFFF',
  outerBorder: '#A5B4FC',
  summaryColor: '#DBEAFE',
  photoSize: 58,
  photoRadius: 8,
  nameFontSize: 24,
  bodyPaddingV: 24,
  bodyPaddingH: 28,
  cardRadius: 16,
  sectionRadius: 12,
  hasPhoto: true
};

// CAMPUS（校园）— 紫色调 + 圆形头像 + 扁平卡片
const CAMPUS_THEME: TemplateVisualTheme = {
  headerBg: '#FFFFFF',
  headerText: '#4C1D95',
  headerSubText: '#7C3AED',
  headerMutedText: '#6B7280',
  nameColor: '#4C1D95',
  positionColor: '#7C3AED',
  contactColor: '#6B7280',
  accentColor: '#7C3AED',
  softColor: '#EDE9FE',
  cardBg: '#FFFFFF',
  cardBorder: '#DDD6FE',
  sectionTitleColor: '#7C3AED',
  sectionContentColor: '#1F2937',
  sectionBg: '#F5F3FF',
  sectionBorder: '#DDD6FE',
  skillTagBg: '#EDE9FE',
  skillTagText: '#7C3AED',
  skillTagBorder: '#C7D2FE',
  dividerColor: '#DDD6FE',
  bodyBg: '#FFFFFF',
  outerBorder: '#DDD6FE',
  summaryColor: '#4B5563',
  photoSize: 64,
  photoRadius: 32,
  nameFontSize: 26,
  bodyPaddingV: 24,
  bodyPaddingH: 28,
  cardRadius: 16,
  sectionRadius: 12,
  hasPhoto: true
};

// EXECUTIVE（商务）— 暖金/琥珀色调
const EXECUTIVE_THEME: TemplateVisualTheme = {
  headerBg: '#FFFFFF',
  headerText: '#111827',
  headerSubText: '#92400E',
  headerMutedText: '#6B7280',
  nameColor: '#111827',
  positionColor: '#92400E',
  contactColor: '#6B7280',
  accentColor: '#B45309',
  softColor: '#FEF3C7',
  cardBg: '#FFFFFF',
  cardBorder: '#D4AF37',
  sectionTitleColor: '#92400E',
  sectionContentColor: '#374151',
  sectionBg: '#FFFBEB',
  sectionBorder: '#FDE68A',
  skillTagBg: '#FFFFFF',
  skillTagText: '#FFFFFF',
  skillTagBorder: '#FFFFFF',
  dividerColor: '#B45309',
  bodyBg: '#FFFFFF',
  outerBorder: '#D4AF37',
  summaryColor: '#374151',
  photoSize: 68,
  photoRadius: 10,
  nameFontSize: 28,
  bodyPaddingV: 24,
  bodyPaddingH: 28,
  cardRadius: 16,
  sectionRadius: 12,
  hasPhoto: false
};

// MINIMAL（极简）— 全灰白极简，无头像
const MINIMAL_THEME: TemplateVisualTheme = {
  headerBg: '#FFFFFF',
  headerText: '#111827',
  headerSubText: '#4B5563',
  headerMutedText: '#6B7280',
  nameColor: '#111827',
  positionColor: '#4B5563',
  contactColor: '#6B7280',
  accentColor: '#374151',
  softColor: '#F3F4F6',
  cardBg: '#FFFFFF',
  cardBorder: '#E5E7EB',
  sectionTitleColor: '#374151',
  sectionContentColor: '#4B5563',
  sectionBg: '#FFFFFF',
  sectionBorder: '#FFFFFF',
  skillTagBg: '#FFFFFF',
  skillTagText: '#FFFFFF',
  skillTagBorder: '#FFFFFF',
  dividerColor: '#E5E7EB',
  bodyBg: '#FFFFFF',
  outerBorder: '#E5E7EB',
  summaryColor: '#4B5563',
  photoSize: 0,
  photoRadius: 0,
  nameFontSize: 30,
  bodyPaddingV: 24,
  bodyPaddingH: 28,
  cardRadius: 16,
  sectionRadius: 12,
  hasPhoto: false
};

// BLACK_GOLD（黑金）— 全暗色背景 + 金色高亮 + 圆形头像
const BLACK_GOLD_THEME: TemplateVisualTheme = {
  headerBg: '#111827',
  headerText: '#FFFFFF',
  headerSubText: '#FCD34D',
  headerMutedText: '#D1D5DB',
  nameColor: '#FFFFFF',
  positionColor: '#FCD34D',
  contactColor: '#D1D5DB',
  accentColor: '#D4AF37',
  softColor: '#1F2937',
  cardBg: '#1F2937',
  cardBorder: '#D4AF37',
  sectionTitleColor: '#D4AF37',
  sectionContentColor: '#D1D5DB',
  sectionBg: '#1F2937',
  sectionBorder: '#1F2937',
  skillTagBg: '#FCD34D',
  skillTagText: '#111827',
  skillTagBorder: '#FCD34D',
  dividerColor: '#D4AF37',
  bodyBg: '#1F2937',
  outerBorder: '#D4AF37',
  summaryColor: '#D1D5DB',
  photoSize: 62,
  photoRadius: 31,
  nameFontSize: 28,
  bodyPaddingV: 24,
  bodyPaddingH: 28,
  cardRadius: 16,
  sectionRadius: 12,
  hasPhoto: true
};

// 主题映射表
const THEME_MAP: Map<ResumeTemplateType, TemplateVisualTheme> = new Map<ResumeTemplateType, TemplateVisualTheme>();
THEME_MAP.set(ResumeTemplateType.STANDARD, STANDARD_THEME);
THEME_MAP.set(ResumeTemplateType.TECHNICAL, TECHNICAL_THEME);
THEME_MAP.set(ResumeTemplateType.CAMPUS, CAMPUS_THEME);
THEME_MAP.set(ResumeTemplateType.EXECUTIVE, EXECUTIVE_THEME);
THEME_MAP.set(ResumeTemplateType.MINIMAL, MINIMAL_THEME);
THEME_MAP.set(ResumeTemplateType.BLACK_GOLD, BLACK_GOLD_THEME);

export function getTemplateTheme(templateType: ResumeTemplateType): TemplateVisualTheme {
  const theme = THEME_MAP.get(templateType);
  if (theme !== undefined) {
    return theme;
  }
  return STANDARD_THEME;
}
