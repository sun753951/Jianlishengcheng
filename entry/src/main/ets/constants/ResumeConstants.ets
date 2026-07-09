import { ResumeTemplateType, TemplateOption } from '../model/ResumeModels';

export const TEMPLATE_OPTIONS: TemplateOption[] = [
  {
    templateType: ResumeTemplateType.STANDARD,
    title: '标准模板',
    description: '适合通用岗位，结构完整，表达稳重。'
  },
  {
    templateType: ResumeTemplateType.TECHNICAL,
    title: '技术岗位模板',
    description: '突出技能栈、项目经验和岗位关键词。'
  },
  {
    templateType: ResumeTemplateType.CAMPUS,
    title: '校园招聘模板',
    description: '强调教育背景、实训经历和学习能力。'
  },
  {
    templateType: ResumeTemplateType.EXECUTIVE,
    title: '高级商务模板',
    description: '黑白金点缀，突出履历层次和结果导向。'
  },
  {
    templateType: ResumeTemplateType.MINIMAL,
    title: '极简灰白模板',
    description: '大留白、细分割线，适合正式投递。'
  },
  {
    templateType: ResumeTemplateType.BLACK_GOLD,
    title: '黑金双栏模板',
    description: '深色侧栏和金色强调，展示高级质感。'
  }
];

export const PROMPT_EXPLANATION: string =
  '根据候选人信息、目标岗位、模板风格和真实性约束生成结构化简历，不编造学历、公司、证书或项目成果。';
