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
    education: '华南理工大学 软件工程 本科 | 2019 - 2023\n主修课程: 数据结构、操作系统、计算机网络、数据库原理\nGPA: 3.6/4.0 校级优秀毕业生',
    targetPosition: 'HarmonyOS 应用开发工程师',
    skills: 'ArkTS, ArkUI, TypeScript, JavaScript, Python, MySQL, Git, Linux\n熟悉 HarmonyOS 应用架构、组件化开发和状态管理\n了解 HTTP 协议、RESTful API 设计、WebSocket 实时通信',
    workExperience: '某科技有限公司 | HarmonyOS 开发实习生 | 2022.06 - 2022.12\n• 参与公司内部管理系统 ArkUI 页面开发，完成 15+ 个业务页面\n• 使用 @State/@Link 实现跨组件数据同步，优化页面渲染性能\n• 封装通用组件库 8 个，减少团队重复开发工作量 30%',
    projectExperience: '智能简历生成系统 | 前端负责人 | 2023.03 - 2023.06\n• 基于 ArkTS + ArkUI 实现 4 步向导式简历生成流程\n• 设计 6 套简历模板（标准/技术/校园/商务/极简/黑金）\n• 集成 WebView createPdf() 实现客户端 PDF 生成\n• 实现 HTTP Server 支持 PC 端一键下载简历 PDF\n\n校园二手交易平台 | 后端开发 | 2022.09 - 2022.12\n• 使用 Python FastAPI 构建 RESTful API，完成用户认证和商品管理模块\n• MySQL 数据库设计，优化慢查询使首页加载速度提升 40%',
    selfEvaluation: '具备扎实的 ArkTS/ArkUI 开发能力，熟悉 HarmonyOS 应用开发全流程\n注重代码规范和文档编写，善于通过技术博客和开源项目持续学习\n良好的团队协作和沟通能力，在校期间多次担任课程项目组长'
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

// 跨页面共享简历数据的单例 Holdern// 方式A：所有页面通过 ResumeDataHolder.getInstance() 读写同一份数据
export class ResumeDataHolder {
  private static instance: ResumeDataHolder;

  formData: ResumeFormData = createDefaultResumeForm();
  selectedTemplate: ResumeTemplateType = ResumeTemplateType.STANDARD;
  generatedResume: string = '';
  previewData: ResumePreviewData = createEmptyResumePreview();
  scoreValue: number = 0;
  scoreLevel: string = '';
  suggestions: string[] = [];

  static getInstance(): ResumeDataHolder {
    if (!ResumeDataHolder.instance) {
      ResumeDataHolder.instance = new ResumeDataHolder();
    }
    return ResumeDataHolder.instance;
  }

  // 返回首页时调用，清空所有数据，开启新一轮
  reset(): void {
    this.formData = createDefaultResumeForm();
    this.selectedTemplate = ResumeTemplateType.STANDARD;
    this.generatedResume = '';
    this.previewData = createEmptyResumePreview();
    this.scoreValue = 0;
    this.scoreLevel = '';
    this.suggestions = [];
  }
}
