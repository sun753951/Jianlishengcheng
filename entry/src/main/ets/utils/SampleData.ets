/**
 * 示例数据 — 提供预填充的简历样本数据，用于演示和测试
 */
import {
  ResumeData, PersonalInfo, Education, WorkExperience,
  Project, Skill, Language, Certificate
} from '../model/ResumeData';

export class SampleData {
  static getSampleResume(): ResumeData {
    const resume: ResumeData = {
      id: 'sample-001',
      createdAt: '2026-01-15',
      updatedAt: '2026-01-15',
      templateType: 'classic',
      colorScheme: 'blue',
      personalInfo: SampleData.createPersonalInfo(),
      education: SampleData.createEducationList(),
      workExperience: SampleData.createWorkList(),
      projects: SampleData.createProjectList(),
      skills: SampleData.createSkillList(),
      languages: SampleData.createLanguageList(),
      certificates: SampleData.createCertificateList(),
      customSections: []
    };
    return resume;
  }

  static createPersonalInfo(): PersonalInfo {
    const info: PersonalInfo = {
      name: '张三',
      gender: '男',
      birthDate: '1998-06-15',
      phone: '138-0000-1234',
      email: 'zhangsan@example.com',
      address: '北京市海淀区中关村',
      title: '高级软件工程师',
      summary: '5年全栈开发经验，精通Java和Spring Cloud微服务架构。主导过3个日均百万级用户平台的架构设计与落地，擅长性能优化与团队协作。',
      avatarUri: '',
      website: 'https://zhangsan.dev',
      linkedIn: 'linkedin.com/in/zhangsan',
      github: 'github.com/zhangsan'
    };
    return info;
  }

  static createEducationList(): Education[] {
    const edu1: Education = {
      id: 'edu-1',
      school: '北京大学',
      degree: '硕士',
      major: '计算机科学与技术',
      startDate: '2020-09',
      endDate: '2023-06',
      description: '研究方向：分布式系统与云计算。发表SCI论文2篇。',
      gpa: '3.8/4.0'
    };
    const edu2: Education = {
      id: 'edu-2',
      school: '武汉大学',
      degree: '学士',
      major: '软件工程',
      startDate: '2016-09',
      endDate: '2020-06',
      description: '获国家奖学金，ACM-ICPC亚洲区域赛银牌。',
      gpa: '3.6/4.0'
    };
    return [edu1, edu2];
  }

  static createWorkList(): WorkExperience[] {
    const work1: WorkExperience = {
      id: 'work-1',
      company: '字节跳动',
      position: '高级后端工程师',
      startDate: '2023-07',
      endDate: '2026-01',
      current: true,
      description: '负责抖音电商核心交易系统开发与维护。',
      achievements: [
        '主导订单系统架构升级，支撑日均5000万订单处理，系统可用性提升至99.99%',
        '设计并实现分布式事务方案，将数据一致性错误率降低80%',
        '带领5人团队完成支付网关改造，支付成功率从97%提升至99.5%'
      ],
      achievementItems: []
    };
    const work2: WorkExperience = {
      id: 'work-2',
      company: '美团',
      position: 'Java开发工程师',
      startDate: '2020-07',
      endDate: '2023-06',
      current: false,
      description: '参与美团外卖商家端核心功能开发。',
      achievements: [
        '开发智能调度系统，将骑手平均配送时间缩短15%',
        '重构地理围栏服务，查询性能提升10倍',
        '获年度最佳新人奖'
      ],
      achievementItems: []
    };
    return [work1, work2];
  }

  static createProjectList(): Project[] {
    const proj1: Project = {
      id: 'proj-1',
      name: '分布式任务调度平台',
      role: '技术负责人',
      startDate: '2024-03',
      endDate: '2024-12',
      description: '面向公司内部的统一任务调度平台，支持定时、延时、批量任务。',
      highlights: [
        '基于Quartz + Redis实现分布式调度，支持10万+任务并发',
        '设计任务执行引擎，支持任务失败自动重试与降级'
      ],
      technologies: ['Java', 'Spring Boot', 'Redis', 'MySQL', 'Docker']
    };
    const proj2: Project = {
      id: 'proj-2',
      name: '电商实时数据看板',
      role: '核心开发',
      startDate: '2023-09',
      endDate: '2024-02',
      description: '实时展示GMV、订单量、转化率等核心指标的数据可视化平台。',
      highlights: [
        '使用Flink处理实时数据流，延迟控制在毫秒级',
        '前端使用Vue3 + ECharts实现动态图表'
      ],
      technologies: ['Flink', 'Kafka', 'Elasticsearch', 'Vue3', 'TypeScript']
    };
    return [proj1, proj2];
  }

  static createSkillList(): Skill[] {
    const skill1: Skill = {
      id: 'skill-1', name: 'Java', level: 95, category: '编程语言'
    };
    const skill2: Skill = {
      id: 'skill-2', name: 'Spring Boot', level: 90, category: '后端框架'
    };
    const skill3: Skill = {
      id: 'skill-3', name: 'MySQL', level: 90, category: '数据库'
    };
    const skill4: Skill = {
      id: 'skill-4', name: 'Redis', level: 85, category: '中间件'
    };
    const skill5: Skill = {
      id: 'skill-5', name: 'Docker', level: 80, category: 'DevOps'
    };
    const skill6: Skill = {
      id: 'skill-6', name: 'TypeScript', level: 75, category: '编程语言'
    };
    const skill7: Skill = {
      id: 'skill-7', name: 'Kubernetes', level: 70, category: 'DevOps'
    };
    const skill8: Skill = {
      id: 'skill-8', name: '系统设计', level: 90, category: '软技能'
    };
    return [skill1, skill2, skill3, skill4, skill5, skill6, skill7, skill8];
  }

  static createLanguageList(): Language[] {
    const lang1: Language = {
      id: 'lang-1', name: '英语', level: 'CET-6 (580分)'
    };
    const lang2: Language = {
      id: 'lang-2', name: '普通话', level: '二级甲等'
    };
    return [lang1, lang2];
  }

  static createCertificateList(): Certificate[] {
    const cert1: Certificate = {
      id: 'cert-1', name: 'AWS Solutions Architect Associate', issuer: 'Amazon', date: '2024-08'
    };
    const cert2: Certificate = {
      id: 'cert-2', name: 'PMP项目管理认证', issuer: 'PMI', date: '2023-12'
    };
    return [cert1, cert2];
  }

  static getEmptyResume(): ResumeData {
    const resume: ResumeData = {
      id: '',
      createdAt: '',
      updatedAt: '',
      templateType: 'classic',
      colorScheme: 'blue',
      personalInfo: new PersonalInfo(),
      education: [],
      workExperience: [],
      projects: [],
      skills: [],
      languages: [],
      certificates: [],
      customSections: []
    };
    return resume;
  }
}
