/**
 * 模板配置模型 — 定义简历模板类型、配色方案、布局参数
 */

// ==================== 模板类型枚举 ====================
export enum TemplateType {
  CLASSIC = 'classic',
  MODERN = 'modern',
  MINIMAL = 'minimal'
}

// ==================== 配色方案枚举 ====================
export enum ColorScheme {
  BLUE = 'blue',
  GREEN = 'green',
  DARK = 'dark',
  PURPLE = 'purple',
  ORANGE = 'orange'
}

// ==================== 字体大小枚举 ====================
export enum FontSize {
  SMALL = 'small',
  MEDIUM = 'medium',
  LARGE = 'large'
}

// ==================== 页眉样式 ====================
export enum HeaderStyle {
  FULL = 'full',
  SIDEBAR = 'sidebar',
  COMPACT = 'compact'
}

// ==================== 板块显示配置 ====================
export class SectionVisibility {
  personalInfo: boolean = true;
  education: boolean = true;
  workExperience: boolean = true;
  projects: boolean = true;
  skills: boolean = true;
  languages: boolean = true;
  certificates: boolean = true;
  customSections: boolean = true;
}

// ==================== 配色映射 ====================
export class ColorPalette {
  primary: string = '#1677FF';
  secondary: string = '#E8F4FF';
  background: string = '#FFFFFF';
  textPrimary: string = '#1A1A1A';
  textSecondary: string = '#666666';
  border: string = '#E5E5E5';
  accent: string = '#FF6B35';
}

// ==================== 模板配置 ====================
export class TemplateConfig {
  id: string = '';
  type: TemplateType = TemplateType.CLASSIC;
  name: string = '';
  description: string = '';
  thumbnailUri: string = '';
  colorScheme: ColorScheme = ColorScheme.BLUE;
  palette: ColorPalette = new ColorPalette();
  fontSize: FontSize = FontSize.MEDIUM;
  headerStyle: HeaderStyle = HeaderStyle.FULL;
  sectionSpacing: number = 20;
  showPhoto: boolean = false;
  sectionVisibility: SectionVisibility = new SectionVisibility();
  isCustomColor: boolean = false;
}

// ==================== 预设模板 ====================
export class TemplatePreset {
  static createClassicBlue(): TemplateConfig {
    const config: TemplateConfig = {
      id: 'classic-blue',
      type: TemplateType.CLASSIC,
      name: '经典蓝',
      description: '传统优雅的简历风格，适合多数行业',
      thumbnailUri: '',
      colorScheme: ColorScheme.BLUE,
      palette: {
        primary: '#1A56DB',
        secondary: '#EBF4FF',
        background: '#FFFFFF',
        textPrimary: '#1A1A1A',
        textSecondary: '#6B7280',
        border: '#D1D5DB',
        accent: '#3B82F6'
      },
      fontSize: FontSize.MEDIUM,
      headerStyle: HeaderStyle.FULL,
      sectionSpacing: 20,
      showPhoto: false,
      sectionVisibility: {
        personalInfo: true,
        education: true,
        workExperience: true,
        projects: true,
        skills: true,
        languages: true,
        certificates: true,
        customSections: true
      },
      isCustomColor: false
    };
    return config;
  }

  static createModernGreen(): TemplateConfig {
    const config: TemplateConfig = {
      id: 'modern-green',
      type: TemplateType.MODERN,
      name: '现代绿',
      description: '现代简洁设计，突出个人品牌',
      thumbnailUri: '',
      colorScheme: ColorScheme.GREEN,
      palette: {
        primary: '#059669',
        secondary: '#ECFDF5',
        background: '#FFFFFF',
        textPrimary: '#111827',
        textSecondary: '#6B7280',
        border: '#D1D5DB',
        accent: '#10B981'
      },
      fontSize: FontSize.MEDIUM,
      headerStyle: HeaderStyle.SIDEBAR,
      sectionSpacing: 16,
      showPhoto: true,
      sectionVisibility: {
        personalInfo: true,
        education: true,
        workExperience: true,
        projects: true,
        skills: true,
        languages: true,
        certificates: true,
        customSections: true
      },
      isCustomColor: false
    };
    return config;
  }

  static createMinimalDark(): TemplateConfig {
    const config: TemplateConfig = {
      id: 'minimal-dark',
      type: TemplateType.MINIMAL,
      name: '极简黑',
      description: '极简风格，以内容为核心',
      thumbnailUri: '',
      colorScheme: ColorScheme.DARK,
      palette: {
        primary: '#111827',
        secondary: '#F3F4F6',
        background: '#FFFFFF',
        textPrimary: '#111827',
        textSecondary: '#6B7280',
        border: '#E5E7EB',
        accent: '#4B5563'
      },
      fontSize: FontSize.SMALL,
      headerStyle: HeaderStyle.COMPACT,
      sectionSpacing: 24,
      showPhoto: false,
      sectionVisibility: {
        personalInfo: true,
        education: true,
        workExperience: true,
        projects: true,
        skills: true,
        languages: false,
        certificates: false,
        customSections: false
      },
      isCustomColor: false
    };
    return config;
  }

  static getPresets(): TemplateConfig[] {
    return [
      TemplatePreset.createClassicBlue(),
      TemplatePreset.createModernGreen(),
      TemplatePreset.createMinimalDark()
    ];
  }
}
