/**
 * ResumeForm — 5步简历信息填写表单
 */
import router from '@ohos.router';
import {
  ResumeData, PersonalInfo, Education, WorkExperience,
  Project, Skill, Language, Certificate
} from '../model/ResumeData';
import { FormStepIndicator, FormStep } from '../components/FormStepIndicator';

const STEPS: string[] = ['基本信息', '教育经历', '工作经历', '项目经验', '技能特长'];

@Entry
@Component
struct ResumeForm {
  @State currentStep: number = 0;
  @State resumeData: ResumeData = new ResumeData();
  // 基本信息字段
  @State name: string = '';
  @State phone: string = '';
  @State email: string = '';
  @State title: string = '';
  @State summary: string = '';
  // 教育经历
  @State educationList: string = ''; // 临时用字符串占位
  @State schoolInput: string = '';
  @State degreeInput: string = '';
  @State majorInput: string = '';
  // 工作经历
  @State companyInput: string = '';
  @State positionInput: string = '';
  @State workDescInput: string = '';
  // 项目经验
  @State projectNameInput: string = '';
  @State projectRoleInput: string = '';
  @State projectDescInput: string = '';
  // 技能
  @State skillInput: string = '';

  getStepList(): FormStep[] {
    const list: FormStep[] = [];
    for (let i: number = 0; i < STEPS.length; i++) {
      const isCompleted: boolean = i < this.currentStep;
      const isActive: boolean = i === this.currentStep;
      const step: FormStep = new FormStep(STEPS[i], isCompleted, isActive);
      list.push(step);
    }
    return list;
  }

  build() {
    Column() {
      // 顶部标题
      Row() {
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .onClick(() => {
            if (this.currentStep === 0) {
              router.back();
            } else {
              this.currentStep--;
            }
          })

        Text('填写简历')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .margin({ left: 12 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

      // 步骤指示器
      FormStepIndicator({
        steps: this.getStepList(),
        currentStep: this.currentStep
      })
      .margin({ top: 8, bottom: 16 })

      // 步骤内容区
      Scroll() {
        Column() {
          if (this.currentStep === 0) {
            this.buildPersonalInfoStep()
          } else if (this.currentStep === 1) {
            this.buildEducationStep()
          } else if (this.currentStep === 2) {
            this.buildWorkExperienceStep()
          } else if (this.currentStep === 3) {
            this.buildProjectStep()
          } else if (this.currentStep === 4) {
            this.buildSkillsStep()
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 120 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部按钮
      Row() {
        if (this.currentStep > 0) {
          Button('上一步')
            .fontSize(14)
            .fontColor('#6B7280')
            .backgroundColor('#F3F4F6')
            .borderRadius(8)
            .height(44)
            .layoutWeight(1)
            .margin({ right: 12 })
            .onClick(() => {
              this.currentStep--;
            })
        }

        Button(this.currentStep === STEPS.length - 1 ? '开始生成' : '下一步')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#1A56DB')
          .borderRadius(8)
          .height(44)
          .layoutWeight(1)
          .onClick(() => {
            if (this.currentStep < STEPS.length - 1) {
              this.currentStep++;
            } else {
              this.submitForm();
            }
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 24 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // ========== Step 0: 基本信息 ==========
  @Builder
  buildPersonalInfoStep() {
    Column() {
      this.buildSectionTitle('个人基本信息')

      this.buildInputField('姓名', '请输入您的姓名', this.name, (value: string) => { this.name = value; })
      this.buildInputField('手机号码', '请输入手机号码', this.phone, (value: string) => { this.phone = value; })
      this.buildInputField('电子邮箱', '请输入邮箱地址', this.email, (value: string) => { this.email = value; })
      this.buildInputField('意向职位', '例如：高级软件工程师', this.title, (value: string) => { this.title = value; })

      this.buildSectionTitle('个人简介')
      TextArea({ text: this.summary, placeholder: '简要介绍您的职业背景、核心能力和职业目标，AI将帮您优化表达...' })
        .height(100)
        .fontSize(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.summary = value;
        })
    }
  }

  // ========== Step 1: 教育经历 ==========
  @Builder
  buildEducationStep() {
    Column() {
      this.buildSectionTitle('教育经历')

      this.buildInputField('学校名称', '例如：北京大学', this.schoolInput, (value: string) => { this.schoolInput = value; })
      this.buildInputField('学历/学位', '例如：硕士', this.degreeInput, (value: string) => { this.degreeInput = value; })
      this.buildInputField('专业', '例如：计算机科学与技术', this.majorInput, (value: string) => { this.majorInput = value; })

      Text('描述（选填）')
        .fontSize(13)
        .fontColor('#6B7280')
        .margin({ top: 12, bottom: 4 })

      TextArea({ text: '', placeholder: '描述研究方向、主要课程或学术成就...' })
        .height(80)
        .fontSize(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
    }
  }

  // ========== Step 2: 工作经历 ==========
  @Builder
  buildWorkExperienceStep() {
    Column() {
      this.buildSectionTitle('工作经历')

      this.buildInputField('公司名称', '例如：字节跳动', this.companyInput, (value: string) => { this.companyInput = value; })
      this.buildInputField('职位', '例如：高级后端工程师', this.positionInput, (value: string) => { this.positionInput = value; })

      Text('工作描述')
        .fontSize(13)
        .fontColor('#6B7280')
        .margin({ top: 12, bottom: 4 })

      TextArea({ text: this.workDescInput, placeholder: '描述您的主要职责和工作成果，AI将自动提炼亮点...' })
        .height(120)
        .fontSize(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.workDescInput = value;
        })
    }
  }

  // ========== Step 3: 项目经验 ==========
  @Builder
  buildProjectStep() {
    Column() {
      this.buildSectionTitle('项目经验')

      this.buildInputField('项目名称', '例如：电商平台架构升级', this.projectNameInput, (value: string) => { this.projectNameInput = value; })
      this.buildInputField('担任角色', '例如：技术负责人', this.projectRoleInput, (value: string) => { this.projectRoleInput = value; })

      Text('项目描述')
        .fontSize(13)
        .fontColor('#6B7280')
        .margin({ top: 12, bottom: 4 })

      TextArea({ text: this.projectDescInput, placeholder: '描述项目背景、您的贡献和项目成果...' })
        .height(120)
        .fontSize(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.projectDescInput = value;
        })
    }
  }

  // ========== Step 4: 技能特长 ==========
  @Builder
  buildSkillsStep() {
    Column() {
      this.buildSectionTitle('技能特长')

      this.buildInputField('技能名称', '例如：Java, Spring Boot, MySQL（用逗号分隔）', this.skillInput, (value: string) => { this.skillInput = value; })

      Text('提示：AI将自动分析您的技能并生成专业的技能展示板块')
        .fontSize(12)
        .fontColor('#9CA3AF')
        .margin({ top: 8 })

      Blank().height(40)

      Column() {
        Row() {
          Text('✅ ')
            .fontSize(16)
          Text('AI智能排版优化')
            .fontSize(13)
            .fontColor('#4B5563')
        }
        .margin({ top: 8 })

        Row() {
          Text('✅ ')
            .fontSize(16)
          Text('关键词自动匹配')
            .fontSize(13)
            .fontColor('#4B5563')
        }
        .margin({ top: 4 })

        Row() {
          Text('✅ ')
            .fontSize(16)
          Text('多模板一键切换')
            .fontSize(13)
            .fontColor('#4B5563')
        }
        .margin({ top: 4 })

        Row() {
          Text('✅ ')
            .fontSize(16)
          Text('专业排版即刻预览')
            .fontSize(13)
            .fontColor('#4B5563')
        }
        .margin({ top: 4 })
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#F0F9FF')
      .borderRadius(8)
      .margin({ top: 16 })
    }
  }

  // ========== 通用 UI 构建器 ==========
  @Builder
  buildSectionTitle(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor('#1A1A1A')
      .margin({ top: 8, bottom: 12 })
  }

  @Builder
  buildInputField(label: string, placeholder: string, value: string, onChange: (value: string) => void) {
    Column() {
      Text(label)
        .fontSize(13)
        .fontColor('#6B7280')
        .margin({ bottom: 4 })

      TextInput({ text: value, placeholder: placeholder })
        .fontSize(14)
        .backgroundColor('#FFFFFF')
        .borderRadius(8)
        .padding(12)
        .onChange((inputValue: string) => {
          onChange(inputValue);
        })
    }
    .width('100%')
    .margin({ bottom: 12 })
  }

  // ========== 提交表单 ==========
  submitForm(): void {
    // 组装简历数据
    const personalInfo: PersonalInfo = {
      name: this.name,
      gender: '',
      birthDate: '',
      phone: this.phone,
      email: this.email,
      address: '',
      title: this.title,
      summary: this.summary,
      avatarUri: '',
      website: '',
      linkedIn: '',
      github: ''
    };

    const resumeToGenerate: ResumeData = {
      id: '',
      createdAt: '',
      updatedAt: '',
      templateType: 'classic',
      colorScheme: 'blue',
      personalInfo: personalInfo,
      education: [],
      workExperience: [],
      projects: [],
      skills: [],
      languages: [],
      certificates: [],
      customSections: []
    };

    AppStorage.setOrCreate<ResumeData>('pendingResume', resumeToGenerate);
    router.pushUrl({ url: 'pages/Generating' });
  }
}
