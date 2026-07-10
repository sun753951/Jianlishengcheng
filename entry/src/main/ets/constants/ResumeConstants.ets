import { ResumeTemplateType, TemplateOption } from '../model/ResumeModels';

export const TEMPLATE_OPTIONS: TemplateOption[] = [
  {
    templateType: ResumeTemplateType.STANDARD,
    title: '标准模板',
    description: '蓝灰专业调，经典简历结构，适合通用岗位投递。'
  },
  {
    templateType: ResumeTemplateType.TECHNICAL,
    title: '技术岗位模板',
    description: '深蓝科技风，技能胶囊高亮，突出技术栈与项目经验。'
  },
  {
    templateType: ResumeTemplateType.CAMPUS,
    title: '校园招聘模板',
    description: '紫色活力调，圆形大头像，强调教育背景与成长潜力。'
  },
  {
    templateType: ResumeTemplateType.EXECUTIVE,
    title: '高级商务模板',
    description: '暖金商务风，金色分隔线点缀，稳重而有质感。'
  },
  {
    templateType: ResumeTemplateType.MINIMAL,
    title: '极简灰白模板',
    description: '极致简约，无头像纯文字排版，大留白适合正式投递。'
  },
  {
    templateType: ResumeTemplateType.BLACK_GOLD,
    title: '黑金双栏模板',
    description: '深色高级感，金色高亮点缀，展示专业与信赖。'
  }
];

export const PROMPT_EXPLANATION: string =
  '根据候选人信息、目标岗位、模板风格和真实性约束生成结构化简历，不编造学历、公司、证书或项目成果。';
