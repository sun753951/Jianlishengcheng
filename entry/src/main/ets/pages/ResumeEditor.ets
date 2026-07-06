/**
 * ResumeEditor — 简历编辑器，支持 8 大模块的折叠编辑和文本导入
 */
import router from '@ohos.router';
import promptAction from '@ohos.promptAction';
import {
  ResumeData, Education, WorkExperience,
  Project, Skill, Language, Certificate, CustomSection, AchievementItem
} from '../model/ResumeData';
import { CollapsibleSection } from '../components/CollapsibleSection';
import { PersonalInfoEditor } from '../components/PersonalInfoEditor';
import { ItemListEditor } from '../components/ItemListEditor';
import { IdGenerator } from '../utils/IdGenerator';
import { TextImporter } from '../utils/TextImporter';

@Entry
@Component
struct ResumeEditor {
  @State resume: ResumeData = new ResumeData();
  // 折叠状态
  @State personalExpanded: boolean = true;
  @State educationExpanded: boolean = false;
  @State workExpanded: boolean = false;
  @State projectExpanded: boolean = false;
  @State skillExpanded: boolean = false;
  @State languageExpanded: boolean = false;
  @State certExpanded: boolean = false;
  @State customExpanded: boolean = false;
  // 文本导入对话框 — 延迟初始化，避免前向引用导致预览器报错
  private importDialogController: CustomDialogController | null = null;

  aboutToAppear(): void {
    this.importDialogController = new CustomDialogController({
      builder: this.buildTextImportDialog(),
      autoCancel: true,
      alignment: DialogAlignment.Center
    });
  }

  onPageShow(): void {
    const data: ResumeData | undefined = AppStorage.get<ResumeData>('currentResume');
    if (data !== undefined) {
      this.resume = data;
      this.personalExpanded = true;
      this.educationExpanded = this.resume.education.length > 0;
      this.workExpanded = this.resume.workExperience.length > 0;
      this.projectExpanded = this.resume.projects.length > 0;
      this.skillExpanded = this.resume.skills.length > 0;
      this.languageExpanded = this.resume.languages.length > 0;
      this.certExpanded = this.resume.certificates.length > 0;
      this.customExpanded = this.resume.customSections.length > 0;
    }
  }

  build() {
    Column() {
      // 顶栏
      this.buildNavBar()

      // 文本导入入口
      this.buildImportCard()

      // 可滚动内容
      Scroll() {
        Column() {
          // 个人信息
          CollapsibleSection({
            sectionTitle: '个人信息',
            itemCount: 0,
            defaultExpanded: this.personalExpanded,
            childContent: () => { this.buildPersonalSection() }
          })

          // 教育经历
          CollapsibleSection({
            sectionTitle: '教育经历',
            itemCount: this.resume.education.length,
            defaultExpanded: this.educationExpanded,
            childContent: () => { this.buildEducationList() }
          })

          // 工作经历
          CollapsibleSection({
            sectionTitle: '工作经历',
            itemCount: this.resume.workExperience.length,
            defaultExpanded: this.workExpanded,
            childContent: () => { this.buildWorkList() }
          })

          // 项目经历
          CollapsibleSection({
            sectionTitle: '项目经历',
            itemCount: this.resume.projects.length,
            defaultExpanded: this.projectExpanded,
            childContent: () => { this.buildProjectList() }
          })

          // 技能
          CollapsibleSection({
            sectionTitle: '技能特长',
            itemCount: this.resume.skills.length,
            defaultExpanded: this.skillExpanded,
            childContent: () => { this.buildSkillList() }
          })

          // 语言
          CollapsibleSection({
            sectionTitle: '语言能力',
            itemCount: this.resume.languages.length,
            defaultExpanded: this.languageExpanded,
            childContent: () => { this.buildLanguageList() }
          })

          // 证书
          CollapsibleSection({
            sectionTitle: '证书奖项',
            itemCount: this.resume.certificates.length,
            defaultExpanded: this.certExpanded,
            childContent: () => { this.buildCertList() }
          })

          // 自定义模块
          CollapsibleSection({
            sectionTitle: '自定义模块',
            itemCount: this.resume.customSections.length,
            defaultExpanded: this.customExpanded,
            childContent: () => { this.buildCustomList() }
          })

          // 底部留白
          Blank().height(80)
        }
        .width('100%')
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // ==================== 顶栏 ====================
  @Builder
  buildNavBar() {
    Row() {
      Image($r('app.media.startIcon'))
        .width(24)
        .height(24)
        .stateStyles({
          pressed: { .opacity(0.6) }
        })
        .onClick(() => {
          router.back();
        })

      Text('编辑简历')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor('#1A1A1A')
        .margin({ left: 12 })
    }
    .width('100%')
    .padding({ left: 16, right: 16, top: 16, bottom: 12 })
  }

  // ==================== 文本导入入口 ====================
  @Builder
  buildImportCard() {
    Row() {
      Text('📄 从文本导入')
        .fontSize(15)
        .fontColor('#1A56DB')
      Blank()
      Text('▶')
        .fontSize(14)
        .fontColor('#1A56DB')
    }
    .width('100%')
    .padding(16)
    .backgroundColor('#EBF4FF')
    .borderRadius(12)
    .margin({ left: 16, right: 16, top: 12, bottom: 4 })
    .stateStyles({
      pressed: { .backgroundColor('#D6E8FF') }
    })
    .onClick(() => {
      if (this.importDialogController !== null) {
        this.importDialogController.open();
      }
    })
  }

  // ==================== 个人信息模块 ====================
  @Builder
  buildPersonalSection() {
    PersonalInfoEditor({ personalInfo: this.resume.personalInfo })
  }

  // ==================== 教育经历列表 ====================
  @Builder
  buildEducationList() {
    ItemListEditor({
      itemTypeLabel: '教育经历',
      emptyHint: '暂无教育经历，点击下方按钮添加',
      itemCount: this.resume.education.length,
      onAddItem: () => this.addEducation(),
      onDeleteItem: (index: number) => this.deleteEducation(index),
      itemBuilder: (index: number) => { this.buildEducationItem(index) }
    })
  }

  @Builder
  buildEducationItem(index: number) {
    Column() {
      this.buildTextField('学校', this.resume.education[index].school,
        (v: string) => { this.updateEducationField(index, 'school', v); })
      this.buildTextField('学历', this.resume.education[index].degree,
        (v: string) => { this.updateEducationField(index, 'degree', v); })
      this.buildTextField('专业', this.resume.education[index].major,
        (v: string) => { this.updateEducationField(index, 'major', v); })
      this.buildTextField('开始时间', this.resume.education[index].startDate,
        (v: string) => { this.updateEducationField(index, 'startDate', v); })
      this.buildTextField('结束时间', this.resume.education[index].endDate,
        (v: string) => { this.updateEducationField(index, 'endDate', v); })
      this.buildTextAreaField('描述', this.resume.education[index].description, 3,
        (v: string) => { this.updateEducationField(index, 'description', v); })
      this.buildTextField('GPA', this.resume.education[index].gpa,
        (v: string) => { this.updateEducationField(index, 'gpa', v); })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ==================== 工作经历列表 ====================
  @Builder
  buildWorkList() {
    ItemListEditor({
      itemTypeLabel: '工作经历',
      emptyHint: '暂无工作经历，点击下方按钮添加',
      itemCount: this.resume.workExperience.length,
      onAddItem: () => this.addWork(),
      onDeleteItem: (index: number) => this.deleteWork(index),
      itemBuilder: (index: number) => { this.buildWorkItem(index) }
    })
  }

  @Builder
  buildWorkItem(index: number) {
    Column() {
      this.buildTextField('公司', this.resume.workExperience[index].company,
        (v: string) => { this.updateWorkField(index, 'company', v); })
      this.buildTextField('职位', this.resume.workExperience[index].position,
        (v: string) => { this.updateWorkField(index, 'position', v); })
      this.buildTextField('开始时间', this.resume.workExperience[index].startDate,
        (v: string) => { this.updateWorkField(index, 'startDate', v); })

      // 至今开关
      Row() {
        Text('至今')
          .fontSize(12)
          .fontColor('#6B7280')
          .margin({ right: 8 })
        Toggle({ type: ToggleType.Checkbox, isOn: this.resume.workExperience[index].current })
          .onChange((isOn: boolean) => {
            this.updateWorkCurrent(index, isOn);
          })
      }
      .width('100%')
      .margin({ bottom: 10 })
      .alignItems(VerticalAlign.Center)

      if (!this.resume.workExperience[index].current) {
        this.buildTextField('结束时间', this.resume.workExperience[index].endDate,
          (v: string) => { this.updateWorkField(index, 'endDate', v); })
      }

      this.buildTextAreaField('工作描述', this.resume.workExperience[index].description, 4,
        (v: string) => { this.updateWorkField(index, 'description', v); })

      // 成就列表
      Text('工作成就')
        .fontSize(12)
        .fontColor('#6B7280')
        .margin({ top: 4, bottom: 8 })

      if (this.resume.workExperience[index].achievementItems.length > 0) {
        ForEach(this.resume.workExperience[index].achievementItems,
          (ach: AchievementItem) => {
            Row() {
              TextInput({ text: ach.content, placeholder: '成就描述' })
                .fontSize(13)
                .fontColor('#1A1A1A')
                .backgroundColor('#F9FAFB')
                .borderRadius(6)
                .padding(8)
                .layoutWeight(1)
                .onChange((v: string) => {
                  this.updateAchievement(index, ach.id, v);
                })
              Button('删除')
                .fontSize(11)
                .fontColor('#EF4444')
                .backgroundColor('#FEE2E2')
                .borderRadius(4)
                .height(32)
                .margin({ left: 8 })
                .stateStyles({
                  pressed: { .backgroundColor('#DC2626').opacity(0.85) }
                })
                .onClick(() => {
                  this.deleteAchievement(index, ach.id);
                })
            }
            .width('100%')
            .margin({ top: 4 })
          }, (ach: AchievementItem) => ach.id)
      }

      Button('+ 添加成就')
        .fontSize(12)
        .fontColor('#1A56DB')
        .backgroundColor('#EBF4FF')
        .borderRadius(6)
        .height(32)
        .width('100%')
        .margin({ top: 8 })
        .stateStyles({
          pressed: { .opacity(0.7) }
        })
        .onClick(() => {
          this.addAchievement(index);
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ==================== 项目经历列表 ====================
  @Builder
  buildProjectList() {
    ItemListEditor({
      itemTypeLabel: '项目经历',
      emptyHint: '暂无项目经历，点击下方按钮添加',
      itemCount: this.resume.projects.length,
      onAddItem: () => this.addProject(),
      onDeleteItem: (index: number) => this.deleteProject(index),
      itemBuilder: (index: number) => { this.buildProjectItem(index) }
    })
  }

  @Builder
  buildProjectItem(index: number) {
    Column() {
      this.buildTextField('项目名称', this.resume.projects[index].name,
        (v: string) => { this.updateProjectField(index, 'name', v); })
      this.buildTextField('担任角色', this.resume.projects[index].role,
        (v: string) => { this.updateProjectField(index, 'role', v); })
      this.buildTextField('开始时间', this.resume.projects[index].startDate,
        (v: string) => { this.updateProjectField(index, 'startDate', v); })
      this.buildTextField('结束时间', this.resume.projects[index].endDate,
        (v: string) => { this.updateProjectField(index, 'endDate', v); })
      this.buildTextAreaField('项目描述', this.resume.projects[index].description, 4,
        (v: string) => { this.updateProjectField(index, 'description', v); })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ==================== 技能列表 ====================
  @Builder
  buildSkillList() {
    ItemListEditor({
      itemTypeLabel: '技能特长',
      emptyHint: '暂无技能，点击下方按钮添加',
      itemCount: this.resume.skills.length,
      onAddItem: () => this.addSkill(),
      onDeleteItem: (index: number) => this.deleteSkill(index),
      itemBuilder: (index: number) => { this.buildSkillItem(index) }
    })
  }

  @Builder
  buildSkillItem(index: number) {
    Column() {
      this.buildTextField('技能名称', this.resume.skills[index].name,
        (v: string) => { this.updateSkillField(index, 'name', v); })
      this.buildTextField('类别', this.resume.skills[index].category,
        (v: string) => { this.updateSkillField(index, 'category', v); })

      Text('熟练度 (' + this.resume.skills[index].level.toString() + ')')
        .fontSize(12)
        .fontColor('#6B7280')
        .margin({ bottom: 4 })
      Slider({
        value: this.resume.skills[index].level,
        min: 0,
        max: 100,
        step: 5
      })
        .width('100%')
        .onChange((value: number) => {
          this.updateSkillLevel(index, value);
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ==================== 语言列表 ====================
  @Builder
  buildLanguageList() {
    ItemListEditor({
      itemTypeLabel: '语言能力',
      emptyHint: '暂无语言能力，点击下方按钮添加',
      itemCount: this.resume.languages.length,
      onAddItem: () => this.addLanguage(),
      onDeleteItem: (index: number) => this.deleteLanguage(index),
      itemBuilder: (index: number) => { this.buildLanguageItem(index) }
    })
  }

  @Builder
  buildLanguageItem(index: number) {
    Column() {
      this.buildTextField('语言名称', this.resume.languages[index].name,
        (v: string) => { this.updateLanguageField(index, 'name', v); })
      this.buildTextField('熟练程度', this.resume.languages[index].level,
        (v: string) => { this.updateLanguageField(index, 'level', v); })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ==================== 证书列表 ====================
  @Builder
  buildCertList() {
    ItemListEditor({
      itemTypeLabel: '证书奖项',
      emptyHint: '暂无证书奖项，点击下方按钮添加',
      itemCount: this.resume.certificates.length,
      onAddItem: () => this.addCertificate(),
      onDeleteItem: (index: number) => this.deleteCertificate(index),
      itemBuilder: (index: number) => { this.buildCertItem(index) }
    })
  }

  @Builder
  buildCertItem(index: number) {
    Column() {
      this.buildTextField('证书/奖项名称', this.resume.certificates[index].name,
        (v: string) => { this.updateCertField(index, 'name', v); })
      this.buildTextField('颁发机构', this.resume.certificates[index].issuer,
        (v: string) => { this.updateCertField(index, 'issuer', v); })
      this.buildTextField('获得时间', this.resume.certificates[index].date,
        (v: string) => { this.updateCertField(index, 'date', v); })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ==================== 自定义模块列表 ====================
  @Builder
  buildCustomList() {
    ItemListEditor({
      itemTypeLabel: '自定义模块',
      emptyHint: '暂无自定义模块，点击下方按钮添加',
      itemCount: this.resume.customSections.length,
      onAddItem: () => this.addCustomSection(),
      onDeleteItem: (index: number) => this.deleteCustomSection(index),
      itemBuilder: (index: number) => { this.buildCustomItem(index) }
    })
  }

  @Builder
  buildCustomItem(index: number) {
    Column() {
      this.buildTextField('模块标题', this.resume.customSections[index].title,
        (v: string) => { this.updateCustomField(index, 'title', v); })
      this.buildTextAreaField('模块内容', this.resume.customSections[index].content, 6,
        (v: string) => { this.updateCustomField(index, 'content', v); })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  // ==================== 通用字段构建器 ====================
  @Builder
  buildTextField(label: string, value: string, onChange: (v: string) => void) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor('#6B7280')
        .margin({ bottom: 4 })

      TextInput({ text: value, placeholder: '' })
        .fontSize(14)
        .fontColor('#1A1A1A')
        .backgroundColor('#F9FAFB')
        .borderRadius(8)
        .padding(12)
        .onChange(onChange)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 10 })
  }

  @Builder
  buildTextAreaField(label: string, value: string, rows: number, onChange: (v: string) => void) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor('#6B7280')
        .margin({ bottom: 4 })

      TextArea({ text: value, placeholder: '' })
        .fontSize(14)
        .fontColor('#1A1A1A')
        .backgroundColor('#F9FAFB')
        .borderRadius(8)
        .padding(12)
        .height(rows * 25)
        .onChange(onChange)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 10 })
  }

  // ==================== 通用保存方法 ====================
  saveResume(): void {
    AppStorage.setOrCreate('currentResume', this.resume);
  }

  // ==================== 教育经历 CRUD ====================
  addEducation(): void {
    const edu: Education = new Education();
    edu.id = IdGenerator.generate('edu');
    this.resume.education = [...this.resume.education, edu];
    this.saveResume();
  }

  deleteEducation(index: number): void {
    this.resume.education = this.resume.education.filter((_item: Education, i: number): boolean => i !== index);
    this.saveResume();
  }

  updateEducationField(index: number, field: string, value: string): void {
    const updated: Education[] = [...this.resume.education];
    const src: Education = updated[index];
    const item: Education = new Education();
    item.id = src.id;
    item.school = src.school;
    item.degree = src.degree;
    item.major = src.major;
    item.startDate = src.startDate;
    item.endDate = src.endDate;
    item.description = src.description;
    item.gpa = src.gpa;
    switch (field) {
      case 'school': item.school = value; break;
      case 'degree': item.degree = value; break;
      case 'major': item.major = value; break;
      case 'startDate': item.startDate = value; break;
      case 'endDate': item.endDate = value; break;
      case 'description': item.description = value; break;
      case 'gpa': item.gpa = value; break;
    }
    updated[index] = item;
    this.resume.education = updated;
    this.saveResume();
  }

  // ==================== 工作经历 CRUD ====================
  addWork(): void {
    const work: WorkExperience = new WorkExperience();
    work.id = IdGenerator.generate('work');
    this.resume.workExperience = [...this.resume.workExperience, work];
    this.saveResume();
  }

  deleteWork(index: number): void {
    this.resume.workExperience = this.resume.workExperience.filter(
      (_item: WorkExperience, i: number): boolean => i !== index);
    this.saveResume();
  }

  updateWorkField(index: number, field: string, value: string): void {
    const updated: WorkExperience[] = [...this.resume.workExperience];
    const src: WorkExperience = updated[index];
    const item: WorkExperience = this.copyWorkExperience(src);
    switch (field) {
      case 'company': item.company = value; break;
      case 'position': item.position = value; break;
      case 'startDate': item.startDate = value; break;
      case 'endDate': item.endDate = value; break;
      case 'description': item.description = value; break;
    }
    updated[index] = item;
    this.resume.workExperience = updated;
    this.saveResume();
  }

  copyWorkExperience(src: WorkExperience): WorkExperience {
    const item: WorkExperience = new WorkExperience();
    item.id = src.id;
    item.company = src.company;
    item.position = src.position;
    item.startDate = src.startDate;
    item.endDate = src.endDate;
    item.current = src.current;
    item.description = src.description;
    item.achievements = [...src.achievements];
    item.achievementItems = src.achievementItems.map(
      (a: AchievementItem): AchievementItem => {
        const copy: AchievementItem = new AchievementItem();
        copy.id = a.id;
        copy.content = a.content;
        return copy;
      });
    return item;
  }

  updateWorkCurrent(index: number, value: boolean): void {
    const updated: WorkExperience[] = [...this.resume.workExperience];
    const src: WorkExperience = updated[index];
    const item: WorkExperience = this.copyWorkExperience(src);
    item.current = value;
    if (value) {
      item.endDate = '';
    }
    updated[index] = item;
    this.resume.workExperience = updated;
    this.saveResume();
  }

  // ==================== 成就条目 CRUD ====================
  addAchievement(workIndex: number): void {
    const ach: AchievementItem = new AchievementItem();
    ach.id = IdGenerator.generate('ach');
    const src: WorkExperience = this.resume.workExperience[workIndex];
    const work: WorkExperience = this.copyWorkExperience(src);
    work.achievementItems = [...work.achievementItems, ach];
    const updated: WorkExperience[] = [...this.resume.workExperience];
    updated[workIndex] = work;
    this.resume.workExperience = updated;
    this.saveResume();
  }

  deleteAchievement(workIndex: number, achId: string): void {
    const src: WorkExperience = this.resume.workExperience[workIndex];
    const work: WorkExperience = this.copyWorkExperience(src);
    work.achievementItems = work.achievementItems.filter(
      (a: AchievementItem): boolean => a.id !== achId);
    work.achievements = work.achievementItems.map((a: AchievementItem): string => a.content);
    const updated: WorkExperience[] = [...this.resume.workExperience];
    updated[workIndex] = work;
    this.resume.workExperience = updated;
    this.saveResume();
  }

  updateAchievement(workIndex: number, achId: string, content: string): void {
    const src: WorkExperience = this.resume.workExperience[workIndex];
    const work: WorkExperience = this.copyWorkExperience(src);
    work.achievementItems = work.achievementItems.map((a: AchievementItem): AchievementItem => {
      if (a.id === achId) {
        const newAch: AchievementItem = new AchievementItem();
        newAch.id = a.id;
        newAch.content = content;
        return newAch;
      }
      return a;
    });
    work.achievements = work.achievementItems.map((a: AchievementItem): string => a.content);
    const updated: WorkExperience[] = [...this.resume.workExperience];
    updated[workIndex] = work;
    this.resume.workExperience = updated;
    this.saveResume();
  }

  // ==================== 项目经历 CRUD ====================
  addProject(): void {
    const proj: Project = new Project();
    proj.id = IdGenerator.generate('proj');
    this.resume.projects = [...this.resume.projects, proj];
    this.saveResume();
  }

  deleteProject(index: number): void {
    this.resume.projects = this.resume.projects.filter(
      (_item: Project, i: number): boolean => i !== index);
    this.saveResume();
  }

  updateProjectField(index: number, field: string, value: string): void {
    const updated: Project[] = [...this.resume.projects];
    const src: Project = updated[index];
    const item: Project = new Project();
    item.id = src.id;
    item.name = src.name;
    item.role = src.role;
    item.startDate = src.startDate;
    item.endDate = src.endDate;
    item.description = src.description;
    item.highlights = [...src.highlights];
    item.technologies = [...src.technologies];
    switch (field) {
      case 'name': item.name = value; break;
      case 'role': item.role = value; break;
      case 'startDate': item.startDate = value; break;
      case 'endDate': item.endDate = value; break;
      case 'description': item.description = value; break;
    }
    updated[index] = item;
    this.resume.projects = updated;
    this.saveResume();
  }

  // ==================== 技能 CRUD ====================
  addSkill(): void {
    const skill: Skill = new Skill();
    skill.id = IdGenerator.generate('skill');
    this.resume.skills = [...this.resume.skills, skill];
    this.saveResume();
  }

  deleteSkill(index: number): void {
    this.resume.skills = this.resume.skills.filter(
      (_item: Skill, i: number): boolean => i !== index);
    this.saveResume();
  }

  updateSkillField(index: number, field: string, value: string): void {
    const updated: Skill[] = [...this.resume.skills];
    const src: Skill = updated[index];
    const item: Skill = new Skill();
    item.id = src.id;
    item.name = src.name;
    item.level = src.level;
    item.category = src.category;
    switch (field) {
      case 'name': item.name = value; break;
      case 'category': item.category = value; break;
    }
    updated[index] = item;
    this.resume.skills = updated;
    this.saveResume();
  }

  updateSkillLevel(index: number, value: number): void {
    const updated: Skill[] = [...this.resume.skills];
    const src: Skill = updated[index];
    const item: Skill = new Skill();
    item.id = src.id;
    item.name = src.name;
    item.level = value;
    item.category = src.category;
    updated[index] = item;
    this.resume.skills = updated;
    this.saveResume();
  }

  // ==================== 语言能力 CRUD ====================
  addLanguage(): void {
    const lang: Language = new Language();
    lang.id = IdGenerator.generate('lang');
    this.resume.languages = [...this.resume.languages, lang];
    this.saveResume();
  }

  deleteLanguage(index: number): void {
    this.resume.languages = this.resume.languages.filter(
      (_item: Language, i: number): boolean => i !== index);
    this.saveResume();
  }

  updateLanguageField(index: number, field: string, value: string): void {
    const updated: Language[] = [...this.resume.languages];
    const src: Language = updated[index];
    const item: Language = new Language();
    item.id = src.id;
    item.name = src.name;
    item.level = src.level;
    switch (field) {
      case 'name': item.name = value; break;
      case 'level': item.level = value; break;
    }
    updated[index] = item;
    this.resume.languages = updated;
    this.saveResume();
  }

  // ==================== 证书 CRUD ====================
  addCertificate(): void {
    const cert: Certificate = new Certificate();
    cert.id = IdGenerator.generate('cert');
    this.resume.certificates = [...this.resume.certificates, cert];
    this.saveResume();
  }

  deleteCertificate(index: number): void {
    this.resume.certificates = this.resume.certificates.filter(
      (_item: Certificate, i: number): boolean => i !== index);
    this.saveResume();
  }

  updateCertField(index: number, field: string, value: string): void {
    const updated: Certificate[] = [...this.resume.certificates];
    const src: Certificate = updated[index];
    const item: Certificate = new Certificate();
    item.id = src.id;
    item.name = src.name;
    item.issuer = src.issuer;
    item.date = src.date;
    switch (field) {
      case 'name': item.name = value; break;
      case 'issuer': item.issuer = value; break;
      case 'date': item.date = value; break;
    }
    updated[index] = item;
    this.resume.certificates = updated;
    this.saveResume();
  }

  // ==================== 自定义模块 CRUD ====================
  addCustomSection(): void {
    const section: CustomSection = new CustomSection();
    section.id = IdGenerator.generate('custom');
    this.resume.customSections = [...this.resume.customSections, section];
    this.saveResume();
  }

  deleteCustomSection(index: number): void {
    this.resume.customSections = this.resume.customSections.filter(
      (_item: CustomSection, i: number): boolean => i !== index);
    this.saveResume();
  }

  updateCustomField(index: number, field: string, value: string): void {
    const updated: CustomSection[] = [...this.resume.customSections];
    const src: CustomSection = updated[index];
    const item: CustomSection = new CustomSection();
    item.id = src.id;
    item.title = src.title;
    item.content = src.content;
    switch (field) {
      case 'title': item.title = value; break;
      case 'content': item.content = value; break;
    }
    updated[index] = item;
    this.resume.customSections = updated;
    this.saveResume();
  }

  // ==================== 文本导入 ====================
  @Builder
  buildTextImportDialog() {
    TextImportDialog({
      onImport: (text: string) => { this.handleTextImport(text); }
    })
  }

  handleTextImport(text: string): void {
    TextImporter.parseResumeText(text);
    if (!TextImporter.isReady()) {
      promptAction.showToast({ message: '文本导入功能即将上线', duration: 2000 });
      return;
    }
  }
}

// ==================== 文本导入对话框 ====================
@CustomDialog
struct TextImportDialog {
  controller: CustomDialogController;
  onImport: (text: string) => void = (_text: string) => {};
  @State inputText: string = '';

  build() {
    Column() {
      Text('从文本导入')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 8 })

      Text('粘贴您的旧简历文本或自我介绍，系统将自动解析为结构化简历内容。')
        .fontSize(13)
        .fontColor('#6B7280')
        .margin({ bottom: 16 })

      TextArea({ text: this.inputText, placeholder: '在此粘贴文本...' })
        .height(200)
        .fontSize(14)
        .backgroundColor('#F9FAFB')
        .borderRadius(8)
        .padding(12)
        .onChange((value: string) => {
          this.inputText = value;
        })

      Row() {
        Button('取消')
          .fontSize(14)
          .fontColor('#6B7280')
          .backgroundColor('#F3F4F6')
          .borderRadius(8)
          .height(44)
          .layoutWeight(1)
          .stateStyles({
            pressed: { .backgroundColor('#E5E7EB') }
          })
          .onClick(() => {
            this.controller.close();
          })
          .margin({ right: 12 })

        Button('开始导入')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#1A56DB')
          .borderRadius(8)
          .height(44)
          .layoutWeight(1)
          .stateStyles({
            pressed: { .backgroundColor('#1649C7') }
          })
          .onClick(() => {
            this.onImport(this.inputText);
            this.controller.close();
          })
      }
      .width('100%')
      .margin({ top: 16 })
    }
    .padding(20)
    .width('100%')
  }
}
