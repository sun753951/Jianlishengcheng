/**
 * 简历数据模型 — 定义简历的全部结构化字段
 */

// ==================== 成就条目 ====================
@Observed
export class AchievementItem {
  id: string = '';
  content: string = '';
}

// ==================== 个人信息 ====================
@Observed
export class PersonalInfo {
  name: string = '';
  gender: string = '';
  birthDate: string = '';
  phone: string = '';
  email: string = '';
  address: string = '';
  title: string = '';
  summary: string = '';
  avatarUri: string = '';
  website: string = '';
  linkedIn: string = '';
  github: string = '';
}

// ==================== 教育经历 ====================
@Observed
export class Education {
  id: string = '';
  school: string = '';
  degree: string = '';
  major: string = '';
  startDate: string = '';
  endDate: string = '';
  description: string = '';
  gpa: string = '';
}

// ==================== 工作经历 ====================
@Observed
export class WorkExperience {
  id: string = '';
  company: string = '';
  position: string = '';
  startDate: string = '';
  endDate: string = '';
  current: boolean = false;
  description: string = '';
  achievements: string[] = [];
  achievementItems: AchievementItem[] = [];
}

// ==================== 项目经历 ====================
@Observed
export class Project {
  id: string = '';
  name: string = '';
  role: string = '';
  startDate: string = '';
  endDate: string = '';
  description: string = '';
  highlights: string[] = [];
  technologies: string[] = [];
}

// ==================== 技能 ====================
@Observed
export class Skill {
  id: string = '';
  name: string = '';
  level: number = 0; // 0-100
  category: string = '';
}

// ==================== 语言能力 ====================
@Observed
export class Language {
  id: string = '';
  name: string = '';
  level: string = '';
}

// ==================== 证书/奖项 ====================
@Observed
export class Certificate {
  id: string = '';
  name: string = '';
  issuer: string = '';
  date: string = '';
}

// ==================== 自定义模块 ====================
@Observed
export class CustomSection {
  id: string = '';
  title: string = '';
  content: string = '';
}

// ==================== 完整简历 ====================
@Observed
export class ResumeData {
  id: string = '';
  createdAt: string = '';
  updatedAt: string = '';
  templateType: string = 'classic';
  colorScheme: string = 'blue';
  personalInfo: PersonalInfo = new PersonalInfo();
  education: Education[] = [];
  workExperience: WorkExperience[] = [];
  projects: Project[] = [];
  skills: Skill[] = [];
  languages: Language[] = [];
  certificates: Certificate[] = [];
  customSections: CustomSection[] = [];
}

// ==================== 简历生成状态 ====================
export enum ResumeGenerateStatus {
  IDLE = 'idle',
  GENERATING = 'generating',
  SUCCESS = 'success',
  FAILED = 'failed'
}

// ==================== 生成结果 ====================
@Observed
export class GenerateResult {
  status: ResumeGenerateStatus = ResumeGenerateStatus.IDLE;
  message: string = '';
  resumeId: string = '';
  progress: number = 0;
  errorCode: number = 0;
}
