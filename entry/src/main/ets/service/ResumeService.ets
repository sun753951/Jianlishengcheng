import { ResumeFormData, ResumePreviewData, ResumePreviewSection, ResumeScoreResult, ResumeTemplateType } from '../model/ResumeModels';

function normalizeText(value: string): string {
  return value.trim();
}

function fallbackText(value: string, fallback: string): string {
  const normalizedValue: string = normalizeText(value);
  if (normalizedValue.length === 0) {
    return fallback;
  }
  return normalizedValue;
}

function hasContent(value: string): boolean {
  return normalizeText(value).length > 0;
}

function getTemplateTitle(templateType: ResumeTemplateType): string {
  if (templateType === ResumeTemplateType.TECHNICAL) {
    return '技术岗位定制简历';
  }
  if (templateType === ResumeTemplateType.CAMPUS) {
    return '校园招聘简历';
  }
  if (templateType === ResumeTemplateType.EXECUTIVE) {
    return '高级商务简历';
  }
  if (templateType === ResumeTemplateType.MINIMAL) {
    return '极简灰白简历';
  }
  if (templateType === ResumeTemplateType.BLACK_GOLD) {
    return '黑金双栏简历';
  }
  return '标准求职简历';
}

function getSummary(formData: ResumeFormData, templateType: ResumeTemplateType): string {
  const targetPosition: string = fallbackText(formData.targetPosition, '目标岗位');
  if (templateType === ResumeTemplateType.TECHNICAL) {
    return `围绕${targetPosition}岗位要求，突出 ArkTS/ArkUI 等技术能力、项目落地经验和工程规范意识。`;
  }
  if (templateType === ResumeTemplateType.CAMPUS) {
    return `面向${targetPosition}岗位，突出教育背景、课程实践、学习能力和成长潜力。`;
  }
  if (templateType === ResumeTemplateType.EXECUTIVE) {
    return `面向${targetPosition}岗位，突出战略视角、跨团队协作、项目推进能力和结果导向。`;
  }
  if (templateType === ResumeTemplateType.MINIMAL) {
    return `围绕${targetPosition}岗位，使用克制清晰的表达呈现教育背景、技能优势和核心经历。`;
  }
  if (templateType === ResumeTemplateType.BLACK_GOLD) {
    return `面向${targetPosition}岗位，突出候选人的核心价值、关键技能和高可信度项目经验。`;
  }
  return `面向${targetPosition}岗位，展示个人基础信息、核心技能、实践经历和职业优势。`;
}

function splitSkillTags(skills: string): string[] {
  const normalizedSkills: string = normalizeText(skills);
  if (normalizedSkills.length === 0) {
    return ['待补充技能'];
  }
  return normalizedSkills
    .replace(/，/g, ',')
    .replace(/、/g, ',')
    .split(',')
    .map((item: string) => item.trim())
    .filter((item: string) => item.length > 0)
    .slice(0, 8);
}

function createSection(title: string, content: string): ResumePreviewSection {
  return {
    title: title,
    content: content
  };
}

export function generateResumePreview(formData: ResumeFormData, templateType: ResumeTemplateType): ResumePreviewData {
  const summary: string = getSummary(formData, templateType);
  const education: string = fallbackText(formData.education, '未填写教育经历');
  const workExperience: string = fallbackText(formData.workExperience, '暂无工作或实习经历，可补充真实经历。');
  const projectExperience: string = fallbackText(formData.projectExperience, '暂无项目经历，可补充课程设计或实践项目。');
  const selfEvaluation: string = fallbackText(formData.selfEvaluation, '暂无自我评价，可补充个人优势和职业态度。');

  let sidebarSections: ResumePreviewSection[] = [
    createSection('教育背景', education),
    createSection('个人优势', selfEvaluation)
  ];
  let mainSections: ResumePreviewSection[] = [
    createSection('个人简介', summary),
    createSection('项目经历', projectExperience),
    createSection('工作/实习经历', workExperience)
  ];

  if (templateType === ResumeTemplateType.CAMPUS) {
    sidebarSections = [
      createSection('教育背景', education),
      createSection('校园/实训亮点', workExperience)
    ];
    mainSections = [
      createSection('求职摘要', summary),
      createSection('项目实践', projectExperience),
      createSection('自我评价', selfEvaluation)
    ];
  }

  if (templateType === ResumeTemplateType.STANDARD) {
    sidebarSections = [
      createSection('联系方式', `${fallbackText(formData.phone, '未填写电话')}\n${fallbackText(formData.email, '未填写邮箱')}`),
      createSection('教育背景', education)
    ];
    mainSections = [
      createSection('个人简介', summary),
      createSection('工作/实习经历', workExperience),
      createSection('项目经历', projectExperience),
      createSection('自我评价', selfEvaluation)
    ];
  }

  if (templateType === ResumeTemplateType.EXECUTIVE) {
    sidebarSections = [
      createSection('核心信息', `${fallbackText(formData.phone, '未填写电话')}\n${fallbackText(formData.email, '未填写邮箱')}\n${education}`),
      createSection('能力标签', splitSkillTags(formData.skills).join(' / '))
    ];
    mainSections = [
      createSection('职业摘要', summary),
      createSection('关键项目', projectExperience),
      createSection('经历亮点', workExperience),
      createSection('个人优势', selfEvaluation)
    ];
  }

  if (templateType === ResumeTemplateType.MINIMAL) {
    sidebarSections = [
      createSection('联系方式', `${fallbackText(formData.phone, '未填写电话')}\n${fallbackText(formData.email, '未填写邮箱')}`),
      createSection('教育', education)
    ];
    mainSections = [
      createSection('摘要', summary),
      createSection('技能', fallbackText(formData.skills, '未填写技能关键词')),
      createSection('项目', projectExperience),
      createSection('经历', workExperience)
    ];
  }

  if (templateType === ResumeTemplateType.BLACK_GOLD) {
    sidebarSections = [
      createSection('PROFILE', summary),
      createSection('CONTACT', `${fallbackText(formData.phone, '未填写电话')}\n${fallbackText(formData.email, '未填写邮箱')}`),
      createSection('EDUCATION', education)
    ];
    mainSections = [
      createSection('SIGNATURE PROJECT', projectExperience),
      createSection('EXPERIENCE', workExperience),
      createSection('STRENGTHS', selfEvaluation)
    ];
  }

  return {
    name: fallbackText(formData.name, '未填写姓名'),
    photoUri: normalizeText(formData.photoUri),
    targetPosition: fallbackText(formData.targetPosition, '未填写求职岗位'),
    phone: fallbackText(formData.phone, '未填写电话'),
    email: fallbackText(formData.email, '未填写邮箱'),
    summary: summary,
    skillTags: splitSkillTags(formData.skills),
    sidebarSections: sidebarSections,
    mainSections: mainSections
  };
}

export function generateResumeText(formData: ResumeFormData, templateType: ResumeTemplateType): string {
  const name: string = fallbackText(formData.name, '未填写姓名');
  const targetPosition: string = fallbackText(formData.targetPosition, '未填写求职岗位');
  const phone: string = fallbackText(formData.phone, '未填写联系电话');
  const email: string = fallbackText(formData.email, '未填写邮箱');
  const education: string = fallbackText(formData.education, '未填写教育经历');
  const skills: string = fallbackText(formData.skills, '未填写技能关键词');
  const workExperience: string = fallbackText(formData.workExperience, '暂无工作或实习经历，可补充真实经历。');
  const projectExperience: string = fallbackText(formData.projectExperience, '暂无项目经历，可补充课程设计或实践项目。');
  const selfEvaluation: string = fallbackText(formData.selfEvaluation, '暂无自我评价，可补充个人优势和职业态度。');

  return `${getTemplateTitle(templateType)}

姓名：${name}
求职岗位：${targetPosition}
联系方式：${phone} / ${email}

个人摘要：
${getSummary(formData, templateType)}

教育经历：
${education}

核心技能：
${skills}

工作/实习经历：
${workExperience}

项目经历：
${projectExperience}

自我评价：
${selfEvaluation}`;
}

function calculateScore(formData: ResumeFormData): number {
  let score: number = 40;
  if (hasContent(formData.name)) {
    score += 8;
  }
  if (hasContent(formData.phone) || hasContent(formData.email)) {
    score += 8;
  }
  if (hasContent(formData.education)) {
    score += 10;
  }
  if (hasContent(formData.targetPosition)) {
    score += 10;
  }
  if (hasContent(formData.skills)) {
    score += 10;
  }
  if (hasContent(formData.workExperience)) {
    score += 7;
  }
  if (hasContent(formData.projectExperience)) {
    score += 7;
  }
  if (hasContent(formData.selfEvaluation)) {
    score += 5;
  }
  if (score > 100) {
    return 100;
  }
  return score;
}

function getScoreLevel(score: number): string {
  if (score >= 90) {
    return '优秀';
  }
  if (score >= 75) {
    return '良好';
  }
  if (score >= 60) {
    return '待完善';
  }
  return '信息不足';
}

function buildSuggestions(formData: ResumeFormData): string[] {
  const suggestions: string[] = [];
  if (!hasContent(formData.targetPosition)) {
    suggestions.push('补充明确的求职岗位，方便生成内容围绕岗位要求展开。');
  }
  if (!hasContent(formData.phone) && !hasContent(formData.email)) {
    suggestions.push('至少填写一种联系方式，避免简历无法被招聘方联系。');
  }
  if (!hasContent(formData.skills)) {
    suggestions.push('补充 3-6 个岗位相关技能关键词，例如 ArkTS、ArkUI、Python。');
  }
  if (!hasContent(formData.projectExperience)) {
    suggestions.push('补充真实项目经历，建议包含项目名称、职责和结果，不编造成果。');
  }
  if (!hasContent(formData.workExperience)) {
    suggestions.push('如没有实习经历，可填写课程实践、社团协作或实训经历。');
  }
  if (suggestions.length === 0) {
    suggestions.push('信息完整度较高，可以继续量化项目成果并优化岗位关键词匹配。');
    suggestions.push('检查简历表述是否真实准确，避免夸大学历、证书或工作年限。');
  }
  return suggestions;
}

export function scoreResume(formData: ResumeFormData): ResumeScoreResult {
  const score: number = calculateScore(formData);
  return {
    score: score,
    level: getScoreLevel(score),
    suggestions: buildSuggestions(formData)
  };
}
