export enum ResumeTemplateType {
  STANDARD = 0,
  TECHNICAL = 1,
  CAMPUS = 2,
  EXECUTIVE = 3,
  MINIMAL = 4,
  BLACK_GOLD = 5
}

export const DEMO_PHOTO_URI: string = 'demo://resume-avatar';

export interface ResumeFormData {
  name: string;
  photoUri: string;
  phone: string;
  email: string;
  education: string;
  targetPosition: string;
  skills: string;
  workExperience: string;
  projectExperience: string;
  selfEvaluation: string;
}

export interface ResumeScoreResult {
  score: number;
  level: string;
  suggestions: string[];
}

export interface ResumePreviewSection {
  title: string;
  content: string;
}

export interface ResumePreviewData {
  name: string;
  photoUri: string;
  targetPosition: string;
  phone: string;
  email: string;
  summary: string;
  skillTags: string[];
  sidebarSections: ResumePreviewSection[];
  mainSections: ResumePreviewSection[];
}

export interface TemplateOption {
  templateType: ResumeTemplateType;
  title: string;
  description: string;
}

export function createDefaultResumeForm(): ResumeFormData {
  return {
    name: '',
    photoUri: '',
    phone: '',
    email: '',
    education: '',
    targetPosition: '',
    skills: '',
    workExperience: '',
    projectExperience: '',
    selfEvaluation: ''
  };
}

export function createDemoResumeForm(): ResumeFormData {
  return {
    name: '李明',
    photoUri: DEMO_PHOTO_URI,
    phone: '13800000000',
    email: 'liming@example.com',
    education: '华南理工大学 软件工程 本科',
    targetPosition: 'HarmonyOS 应用开发工程师',
    skills: 'ArkTS, ArkUI, TypeScript, Python, MySQL',
    workExperience: '在校期间参与移动应用开发实训，负责页面开发、接口联调和测试记录整理。',
    projectExperience: '智能简历生成系统：负责信息填写、模板选择、简历生成、评分建议和导出流程设计。',
    selfEvaluation: '学习能力强，关注代码规范和隐私保护，具备良好的团队协作意识。'
  };
}

export function createEmptyResumePreview(): ResumePreviewData {
  return {
    name: '',
    photoUri: '',
    targetPosition: '',
    phone: '',
    email: '',
    summary: '',
    skillTags: [],
    sidebarSections: [],
    mainSections: []
  };
}
