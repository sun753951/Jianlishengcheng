import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { PROMPT_EXPLANATION, TEMPLATE_OPTIONS } from '../constants/ResumeConstants';
import { ButtonFeedbackState, getButtonFeedbackScale } from '../model/ButtonFeedbackModels';
import { DEMO_PHOTO_URI, ResumeFormData, ResumePreviewData, ResumePreviewSection, ResumeScoreResult, ResumeTemplateType, TemplateOption, createDemoResumeForm, createEmptyResumePreview } from '../model/ResumeModels';
import { GenerateResumeApiResponse, PdfExportResult, requestExportPdf, requestGenerateResume, requestScoreResume } from '../service/ResumeApiService';
import { generateResumePreview, generateResumeText, scoreResume } from '../service/ResumeService';
import { PRIMARY, PRIMARY_DARK, PRIMARY_LIGHT, PRIMARY_BORDER, BG_PAGE, BORDER_DEFAULT } from '../style/Colors';

@Entry
@Component
struct Index {
  @State candidateName: string = '';
  @State photoUri: string = '';
  @State phone: string = '';
  @State email: string = '';
  @State education: string = '';
  @State targetPosition: string = '';
  @State skills: string = '';
  @State workExperience: string = '';
  @State projectExperience: string = '';
  @State selfEvaluation: string = '';
  @State selectedTemplate: ResumeTemplateType = ResumeTemplateType.TECHNICAL;
  @State generatedResume: string = '';
  @State originalGeneratedResume: string = '';
  @State editedResume: string = '';
  @State scoreValue: number = 0;
  @State scoreLevel: string = '未评分';
  @State suggestions: string[] = [];
  @State isGenerating: boolean = false;
  @State isScoring: boolean = false;
  @State isExporting: boolean = false;
  @State errorMessage: string = '';
  @State apiErrorMessage: string = '';
  @State exportStatus: string = '';
  @State previewData: ResumePreviewData = createEmptyResumePreview();
  @State hoveredButtonKey: string = '';
  @State pressedButtonKey: string = '';

  private createFormData(): ResumeFormData {
    return {
      name: this.candidateName,
      photoUri: this.photoUri,
      phone: this.phone,
      email: this.email,
      education: this.education,
      targetPosition: this.targetPosition,
      skills: this.skills,
      workExperience: this.workExperience,
      projectExperience: this.projectExperience,
      selfEvaluation: this.selfEvaluation
    };
  }

  private applyDemoData(): void {
    const demoData: ResumeFormData = createDemoResumeForm();
    this.candidateName = demoData.name;
    this.photoUri = demoData.photoUri;
    this.phone = demoData.phone;
    this.email = demoData.email;
    this.education = demoData.education;
    this.targetPosition = demoData.targetPosition;
    this.skills = demoData.skills;
    this.workExperience = demoData.workExperience;
    this.projectExperience = demoData.projectExperience;
    this.selfEvaluation = demoData.selfEvaluation;
    this.errorMessage = '';
    this.apiErrorMessage = '';
    this.exportStatus = '';
  }

  private async selectPhoto(): Promise<void> {
    try {
      const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
      photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
      photoSelectOptions.maxSelectNumber = 1;
      const photoPicker = new photoAccessHelper.PhotoViewPicker();
      const result: photoAccessHelper.PhotoSelectResult = await photoPicker.select(photoSelectOptions);
      if (result.photoUris.length > 0) {
        this.photoUri = result.photoUris[0];
        this.exportStatus = '';
        if (this.generatedResume.length > 0) {
          this.previewData = generateResumePreview(this.createFormData(), this.selectedTemplate);
        }
      }
    } catch (error) {
      this.errorMessage = '选择照片失败，请重试或检查相册权限。';
    }
  }

  private clearPhoto(): void {
    this.photoUri = '';
    if (this.generatedResume.length > 0) {
      this.previewData = generateResumePreview(this.createFormData(), this.selectedTemplate);
    }
  }

  private isDemoPhoto(photoUri: string): boolean {
    return photoUri === DEMO_PHOTO_URI;
  }

  private validateForm(): boolean {
    if (this.candidateName.trim().length === 0) {
      this.errorMessage = '请填写姓名。';
      return false;
    }
    if (this.targetPosition.trim().length === 0) {
      this.errorMessage = '请填写求职岗位。';
      return false;
    }
    if (this.education.trim().length === 0) {
      this.errorMessage = '请填写教育经历。';
      return false;
    }
    if (this.projectExperience.trim().length === 0) {
      this.errorMessage = '请填写项目经历。';
      return false;
    }
    this.errorMessage = '';
    return true;
  }

  private getCurrentResumeText(): string {
    if (this.editedResume.trim().length > 0) {
      return this.editedResume;
    }
    return this.generatedResume;
  }

  private applyGeneratedResume(resumeText: string, previewData: ResumePreviewData): void {
    this.originalGeneratedResume = resumeText;
    this.generatedResume = resumeText;
    this.editedResume = resumeText;
    this.previewData = previewData;
  }

  private async generateResume(): Promise<void> {
    this.exportStatus = '';
    this.apiErrorMessage = '';
    if (!this.validateForm()) {
      return;
    }
    this.isGenerating = true;
    const formData: ResumeFormData = this.createFormData();
    try {
      const apiResponse: GenerateResumeApiResponse = await requestGenerateResume(formData, this.selectedTemplate);
      this.applyGeneratedResume(apiResponse.resumeText, apiResponse.previewData);
      if (apiResponse.usedFallback) {
        this.apiErrorMessage = '后端已响应，但当前使用规则模板降级生成。';
      }
      const scoreResult: ResumeScoreResult = await requestScoreResume(formData, this.selectedTemplate, this.editedResume);
      this.scoreValue = scoreResult.score;
      this.scoreLevel = scoreResult.level;
      this.suggestions = scoreResult.suggestions;
    } catch (error) {
      const localResumeText: string = generateResumeText(formData, this.selectedTemplate);
      this.applyGeneratedResume(localResumeText, generateResumePreview(formData, this.selectedTemplate));
      const localScoreResult: ResumeScoreResult = scoreResume(formData);
      this.scoreValue = localScoreResult.score;
      this.scoreLevel = localScoreResult.level;
      this.suggestions = localScoreResult.suggestions;
      this.apiErrorMessage = 'AI 服务不可用，已使用本地演示生成。请确认 Python 后端已启动。';
    } finally {
      this.isGenerating = false;
    }
  }

  private async refreshScore(): Promise<void> {
    this.isScoring = true;
    this.apiErrorMessage = '';
    const formData: ResumeFormData = this.createFormData();
    try {
      const scoreResult: ResumeScoreResult = await requestScoreResume(formData, this.selectedTemplate, this.getCurrentResumeText());
      this.scoreValue = scoreResult.score;
      this.scoreLevel = scoreResult.level;
      this.suggestions = scoreResult.suggestions;
    } catch (error) {
      const localScoreResult: ResumeScoreResult = scoreResume(formData);
      this.scoreValue = localScoreResult.score;
      this.scoreLevel = localScoreResult.level;
      this.suggestions = localScoreResult.suggestions;
      this.apiErrorMessage = '评分服务不可用，已使用本地评分规则。';
    } finally {
      this.isScoring = false;
    }
  }

  private getTemplateAccentColor(): string {
    if (this.selectedTemplate === ResumeTemplateType.STANDARD) {
      return '#0F766E';
    }
    if (this.selectedTemplate === ResumeTemplateType.CAMPUS) {
      return '#7C3AED';
    }
    if (this.selectedTemplate === ResumeTemplateType.EXECUTIVE) {
      return '#B45309';
    }
    if (this.selectedTemplate === ResumeTemplateType.MINIMAL) {
      return '#374151';
    }
    if (this.selectedTemplate === ResumeTemplateType.BLACK_GOLD) {
      return '#D4AF37';
    }
    return '#1D4ED8';
  }

  private getTemplateSoftColor(): string {
    if (this.selectedTemplate === ResumeTemplateType.STANDARD) {
      return '#CCFBF1';
    }
    if (this.selectedTemplate === ResumeTemplateType.CAMPUS) {
      return '#EDE9FE';
    }
    if (this.selectedTemplate === ResumeTemplateType.EXECUTIVE) {
      return '#FEF3C7';
    }
    if (this.selectedTemplate === ResumeTemplateType.MINIMAL) {
      return '#F3F4F6';
    }
    if (this.selectedTemplate === ResumeTemplateType.BLACK_GOLD) {
      return '#1F2937';
    }
    return '#DBEAFE';
  }

  private getTemplateCardColor(): string {
    if (this.selectedTemplate === ResumeTemplateType.STANDARD) {
      return '#F8FAFC';
    }
    if (this.selectedTemplate === ResumeTemplateType.CAMPUS) {
      return '#FAF5FF';
    }
    if (this.selectedTemplate === ResumeTemplateType.EXECUTIVE) {
      return '#FFFBEB';
    }
    if (this.selectedTemplate === ResumeTemplateType.MINIMAL) {
      return '#F9FAFB';
    }
    if (this.selectedTemplate === ResumeTemplateType.BLACK_GOLD) {
      return '#111827';
    }
    return '#EFF6FF';
  }

  private async exportPdf(): Promise<void> {
    const resumeText: string = this.getCurrentResumeText();
    if (resumeText.trim().length === 0) {
      this.exportStatus = '请先生成简历，再导出 PDF。';
      return;
    }
    this.isExporting = true;
    this.apiErrorMessage = '';
    try {
      const result: PdfExportResult = await requestExportPdf(this.createFormData(), this.selectedTemplate, resumeText);
      this.exportStatus = `PDF 已由后端生成：${result.fileName}，大小 ${result.data.byteLength} 字节。`;
    } catch (error) {
      this.exportStatus = 'PDF 导出失败，请确认 Python 后端已启动。';
    } finally {
      this.isExporting = false;
    }
  }

  private getInteractiveButtonScale(buttonKey: string): number {
    if (this.pressedButtonKey === buttonKey) {
      return getButtonFeedbackScale(ButtonFeedbackState.PRESSED);
    }
    if (this.hoveredButtonKey === buttonKey) {
      return getButtonFeedbackScale(ButtonFeedbackState.HOVERED);
    }
    return getButtonFeedbackScale(ButtonFeedbackState.NORMAL);
  }

  private getTemplateButtonKey(templateType: ResumeTemplateType): string {
    return `template-${templateType}`;
  }

  private handleButtonHover(buttonKey: string, isHover: boolean): void {
    this.hoveredButtonKey = isHover ? buttonKey : '';
    if (!isHover && this.pressedButtonKey === buttonKey) {
      this.pressedButtonKey = '';
    }
  }

  private handleButtonTouch(buttonKey: string, event: TouchEvent): void {
    if (event.type === TouchType.Down) {
      this.pressedButtonKey = buttonKey;
      return;
    }
    if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
      this.pressedButtonKey = '';
    }
  }

  @Builder
  private heroMetric(label: string, value: string, color: string, backgroundColor: string) {
    Column({ space: 4 }) {
      Text(value)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(color)
      Text(label)
        .fontSize(11)
        .fontColor('#475467')
    }
    .alignItems(HorizontalAlign.Start)
    .layoutWeight(1)
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .borderRadius(12)
    .backgroundColor(backgroundColor)
    .border({ width: 1, color: BORDER_DEFAULT })
  }

  @Builder
  private capabilityTag(label: string) {
    Text(label)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor(PRIMARY_DARK)
      .padding({ left: 10, right: 10, top: 5, bottom: 5 })
      .borderRadius(14)
      .backgroundColor(PRIMARY_LIGHT)
      .border({ width: 1, color: PRIMARY_BORDER })
  }

  @Builder
  private heroPanel() {
    Column({ space: 16 }) {
      Row({ space: 10 }) {
        Text('AI')
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .textAlign(TextAlign.Center)
          .width(42)
          .height(42)
          .borderRadius(14)
          .backgroundColor(PRIMARY)
        Column({ space: 4 }) {
          Text('智能简历生成系统')
            .fontSize(30)
            .fontWeight(FontWeight.Bold)
            .fontColor('#101828')
          Text('填写真实经历，生成更贴合岗位的简历文本、评分建议和导出结果。')
            .fontSize(14)
            .fontColor('#475467')
            .lineHeight(22)
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        this.capabilityTag('自然语言生成')
        this.capabilityTag('模板实时预览')
        this.capabilityTag('评分优化建议')
        this.capabilityTag('PDF 导出')
      }
      .width('100%')

      Row({ space: 10 }) {
        this.heroMetric('核心流程', '6 步', '#2563EB', '#EFF6FF')
        this.heroMetric('简历模板', '6 套', PRIMARY, PRIMARY_LIGHT)
        this.heroMetric('状态反馈', '完整', '#059669', '#ECFDF3')
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(18)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: PRIMARY_BORDER })
    .shadow({ radius: 12, color: 'rgba(0,0,0,0.07)', offsetY: 4 })
  }

  @Builder
  private sectionTitle(title: string, caption: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')
      Text(caption)
        .fontSize(13)
        .fontColor('#6B7280')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  private fieldLabel(label: string, required: boolean) {
    Row({ space: 4 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1F2937')
      if (required) {
        Text('*')
          .fontSize(14)
          .fontColor('#D92D20')
      }
    }
    .width('100%')
  }

  @Builder
  private singleLineInput(label: string, value: string, placeholder: string, required: boolean, onValueChange: (value: string) => void) {
    Column({ space: 6 }) {
      this.fieldLabel(label, required)
      TextInput({ text: value, placeholder: placeholder })
        .height(44)
        .fontSize(15)
        .fontColor('#111827')
        .backgroundColor(PRIMARY_LIGHT)
        .borderRadius(12)
        .border({ width: 1, color: BORDER_DEFAULT })
        .onChange(onValueChange)
    }
    .width('100%')
  }

  @Builder
  private multiLineInput(label: string, value: string, placeholder: string, required: boolean, onValueChange: (value: string) => void) {
    Column({ space: 6 }) {
      this.fieldLabel(label, required)
      TextArea({ text: value, placeholder: placeholder })
        .height(96)
        .fontSize(15)
        .fontColor('#111827')
        .backgroundColor(PRIMARY_LIGHT)
        .borderRadius(12)
        .border({ width: 1, color: BORDER_DEFAULT })
        .onChange(onValueChange)
    }
    .width('100%')
  }

  @Builder
  private templateSelector() {
    Column({ space: 10 }) {
      ForEach(TEMPLATE_OPTIONS, (item: TemplateOption) => {
        Button() {
          Row({ space: 10 }) {
            Text(this.selectedTemplate === item.templateType ? '\u2713' : '\u25CB')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.selectedTemplate === item.templateType ? '#FFFFFF' : PRIMARY)
              .textAlign(TextAlign.Center)
              .width(26)
              .height(26)
              .borderRadius(13)
              .backgroundColor(this.selectedTemplate === item.templateType ? PRIMARY : PRIMARY_LIGHT)
            Column({ space: 4 }) {
              Text(item.title)
                .fontSize(15)
                .fontWeight(FontWeight.Medium)
                .fontColor(this.selectedTemplate === item.templateType ? '#FFFFFF' : '#111827')
              Text(item.description)
                .fontSize(12)
                .fontColor(this.selectedTemplate === item.templateType ? '#E0E7FF' : '#5B6475')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            Text(this.selectedTemplate === item.templateType ? '已选' : '选择')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.selectedTemplate === item.templateType ? '#FFFFFF' : PRIMARY)
              .padding({ left: 9, right: 9, top: 4, bottom: 4 })
              .borderRadius(12)
              .backgroundColor(this.selectedTemplate === item.templateType ? PRIMARY : PRIMARY_LIGHT)
          }
          .width('100%')
        }
        .height(76)
        .padding({ left: 14, right: 14 })
        .borderRadius(14)
        .backgroundColor(this.selectedTemplate === item.templateType ? PRIMARY_DARK : '#F8FAFF')
        .border({ width: 1, color: this.selectedTemplate === item.templateType ? PRIMARY_BORDER : BORDER_DEFAULT })
        .scale({
          x: this.getInteractiveButtonScale(this.getTemplateButtonKey(item.templateType)),
          y: this.getInteractiveButtonScale(this.getTemplateButtonKey(item.templateType))
        })
        .animation({ duration: 120, curve: Curve.EaseOut })
        .onHover((isHover: boolean) => {
          this.handleButtonHover(this.getTemplateButtonKey(item.templateType), isHover);
        })
        .onTouch((event: TouchEvent) => {
          this.handleButtonTouch(this.getTemplateButtonKey(item.templateType), event);
        })
        .onClick(() => {
          this.selectedTemplate = item.templateType;
          this.exportStatus = '';
        })
      }, (item: TemplateOption) => item.templateType.toString())
    }
    .width('100%')
  }

  @Builder
  private scorePanel() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text('简历评分')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor(PRIMARY_DARK)
          Text(this.scoreLevel)
            .fontSize(13)
            .fontColor(PRIMARY)
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        Text(`${this.scoreValue}`)
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor(PRIMARY)
      }
      .width('100%')

      Progress({ value: this.scoreValue, total: 100, type: ProgressType.Linear })
        .width('100%')
        .color(PRIMARY)
        .backgroundColor('#E5E7EB')

      ForEach(this.suggestions, (suggestion: string) => {
        Text(`\u2022 ${suggestion}`)
          .fontSize(13)
          .fontColor('#1F2937')
          .lineHeight(20)
          .width('100%')
      }, (suggestion: string) => suggestion)
    }
    .width('100%')
    .padding(16)
    .borderRadius(16)
    .backgroundColor(PRIMARY_LIGHT)
    .border({ width: 1, color: PRIMARY_BORDER })
  }

  @Builder
  private skillTag(tag: string) {
    Text(tag)
      .fontSize(11)
      .fontColor(this.getTemplateAccentColor())
      .fontWeight(FontWeight.Medium)
      .padding({ left: 9, right: 9, top: 5, bottom: 5 })
      .margin({ right: 8, bottom: 8 })
      .borderRadius(12)
      .backgroundColor(this.getTemplateSoftColor())
      .border({ width: 1, color: PRIMARY_BORDER })
  }

  @Builder
  private photoBox(size: number, radius: number) {
    if (this.previewData.photoUri.length > 0) {
      if (this.isDemoPhoto(this.previewData.photoUri)) {
        Image($r('app.media.startIcon'))
          .width(size)
          .height(size)
          .borderRadius(radius)
          .objectFit(ImageFit.Cover)
          .border({ width: 2, color: BORDER_DEFAULT })
      } else {
        Image(this.previewData.photoUri)
          .width(size)
          .height(size)
          .borderRadius(radius)
          .objectFit(ImageFit.Cover)
          .border({ width: 2, color: BORDER_DEFAULT })
      }
    } else {
      Text(this.previewData.name.substring(0, 1))
        .fontSize(size * 0.42)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
        .textAlign(TextAlign.Center)
        .width(size)
        .height(size)
        .borderRadius(radius)
        .backgroundColor(PRIMARY)
    }
  }

  @Builder
  private resumeSection(section: ResumePreviewSection) {
    Column({ space: 6 }) {
      Row({ space: 8 }) {
        Divider()
          .vertical(true)
          .height(18)
          .strokeWidth(3)
          .color(this.getTemplateAccentColor())
        Text(section.title)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
      }
      .width('100%')
      Text(section.content)
        .fontSize(13)
        .fontColor('#1F2937')
        .lineHeight(20)
        .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
  }

  @Builder
  private compactSection(section: ResumePreviewSection) {
    Column({ space: 5 }) {
      Text(section.title)
        .fontSize(13)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.getTemplateAccentColor())
      Text(section.content)
        .fontSize(12)
        .fontColor('#4B5563')
        .lineHeight(18)
        .width('100%')
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding(10)
    .borderRadius(12)
    .backgroundColor('#F8FAFF')
    .border({ width: 1, color: BORDER_DEFAULT })
  }

  @Builder
  private standardResumePreview() {
    Column({ space: 14 }) {
      Row({ space: 14 }) {
        Column({ space: 5 }) {
          Text(this.previewData.name)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827')
          Text(this.previewData.targetPosition)
            .fontSize(14)
            .fontColor('#374151')
          Text(`${this.previewData.phone}  |  ${this.previewData.email}`)
            .fontSize(12)
            .fontColor('#6B7280')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        this.photoBox(72, 6)
      }
      .width('100%')

      Divider().strokeWidth(1).color('#D1D5DB')

      Text(this.previewData.summary)
        .fontSize(13)
        .fontColor('#374151')
        .lineHeight(20)
      .width('100%')

      Column({ space: 12 }) {
        ForEach(this.previewData.mainSections, (section: ResumePreviewSection) => {
          this.resumeSection(section)
        }, (section: ResumePreviewSection) => section.title)
      }
      .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.previewData.skillTags, (tag: string) => {
          this.skillTag(tag)
        }, (tag: string) => tag)
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#CBD5E1' })
  }

  @Builder
  private technicalResumePreview() {
    Column({ space: 0 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.previewData.name)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
          Text(this.previewData.targetPosition)
            .fontSize(14)
            .fontColor('#BFDBFE')
          Text(`${this.previewData.phone} \uFF5C ${this.previewData.email}`)
            .fontSize(11)
            .fontColor('#93C5FD')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#1E3A8A')

      Row() {
        Column({ space: 10 }) {
          this.photoBox(58, 8)
          Row()
            .width('100%')
            .height(1)
            .backgroundColor('rgba(255,255,255,0.2)')
          Text('技能')
            .fontSize(12)
            .fontWeight(FontWeight.Bold)
            .fontColor('#BFDBFE')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.previewData.skillTags, (tag: string) => {
              Text(tag)
                .fontSize(11)
                .fontColor('#DBEAFE')
                .padding({ left: 9, right: 9, top: 5, bottom: 5 })
                .margin({ right: 6, bottom: 6 })
                .borderRadius(12)
                .backgroundColor('rgba(255,255,255,0.15)')
                .border({ width: 1, color: 'rgba(255,255,255,0.2)' })
            }, (tag: string) => tag)
          }
          .width('100%')
          Row()
            .width('100%')
            .height(1)
            .backgroundColor('rgba(255,255,255,0.2)')
          ForEach(this.previewData.sidebarSections, (section: ResumePreviewSection) => {
            Column({ space: 3 }) {
              Text(section.title)
                .fontSize(12)
                .fontWeight(FontWeight.Bold)
                .fontColor('#BFDBFE')
              Text(section.content)
                .fontSize(11)
                .fontColor('#93C5FD')
                .lineHeight(16)
                .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }, (section: ResumePreviewSection) => section.title)
        }
        .alignItems(HorizontalAlign.Start)
        .width('35%')
        .padding(12)
        .backgroundColor('#1E3A8A')

        Column({ space: 12 }) {
          Text(this.previewData.summary)
            .fontSize(12)
            .fontColor('#374151')
            .lineHeight(18)
            .width('100%')
          ForEach(this.previewData.mainSections, (section: ResumePreviewSection) => {
            Column({ space: 6 }) {
              Text(section.title)
                .fontSize(16)
                .fontWeight(FontWeight.Bold)
                .fontColor('#1E3A8A')
              Text(section.content)
                .fontSize(13)
                .fontColor('#1F2937')
                .lineHeight(20)
                .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
            .padding(12)
            .borderRadius(12)
            .backgroundColor('#F8FAFF')
            .border({ width: 1, color: '#C7D2FE' })
          }, (section: ResumePreviewSection) => section.title)
        }
        .layoutWeight(1)
        .padding(14)
        .backgroundColor('#FFFFFF')
      }
      .width('100%')
    }
    .width('100%')
    .borderRadius(16)
    .clip(true)
    .border({ width: 1, color: '#A5B4FC' })
    .backgroundColor('#FFFFFF')
  }

  private getMergedCampusSections(): ResumePreviewSection[] {
    const allSections: ResumePreviewSection[] = [];
    for (let i = 0; i < this.previewData.sidebarSections.length; i++) {
      allSections.push(this.previewData.sidebarSections[i]);
    }
    for (let i = 0; i < this.previewData.mainSections.length; i++) {
      allSections.push(this.previewData.mainSections[i]);
    }
    return allSections;
  }

  @Builder
  private campusResumePreview() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        this.photoBox(64, 32)
        Column({ space: 6 }) {
          Text(this.previewData.name)
            .fontSize(26)
            .fontWeight(FontWeight.Bold)
            .fontColor('#4C1D95')
          Text(this.previewData.targetPosition)
            .fontSize(14)
            .fontColor('#7C3AED')
          Text(`${this.previewData.phone} \uFF5C ${this.previewData.email}`)
            .fontSize(12)
            .fontColor('#6B7280')
        }
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
      }
      .width('100%')
      .padding(14)
      .borderRadius(14)
      .backgroundColor('#F5F3FF')
      .border({ width: 1, color: '#DDD6FE' })

      Text(this.previewData.summary)
        .fontSize(12)
        .fontColor('#4B5563')
        .lineHeight(18)
        .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.previewData.skillTags, (tag: string) => {
          this.skillTag(tag)
        }, (tag: string) => tag)
      }
      .width('100%')

      Column({ space: 0 }) {
        ForEach(this.getMergedCampusSections(), (section: ResumePreviewSection, index: number) => {
          Row({ space: 8 }) {
            Column() {
              Circle()
                .width(8)
                .height(8)
                .fill('#7C3AED')
              if (index < this.getMergedCampusSections().length - 1) {
                Column()
                  .width(2)
                  .height(40)
                  .backgroundColor('#DDD6FE')
              }
            }
            .alignItems(HorizontalAlign.Center)
            .width(20)

            Column({ space: 5 }) {
              Text(section.title)
                .fontSize(14)
                .fontWeight(FontWeight.Bold)
                .fontColor('#7C3AED')
              Text(section.content)
                .fontSize(13)
                .fontColor('#1F2937')
                .lineHeight(19)
                .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
            .padding({ bottom: 16 })
          }
          .width('100%')
          .alignItems(VerticalAlign.Top)
        }, (section: ResumePreviewSection, index: number) => `${index}_${section.title}`)
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#DDD6FE' })
  }

  @Builder
  private executiveResumePreview() {
    Column({ space: 14 }) {
      Column({ space: 4 }) {
        Text(this.previewData.name)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text(this.previewData.targetPosition)
          .fontSize(13)
          .fontColor('#92400E')
          .fontWeight(FontWeight.Medium)
        Text(`${this.previewData.phone} \uFF5C ${this.previewData.email}`)
          .fontSize(11)
          .fontColor('#6B7280')
      }
      .alignItems(HorizontalAlign.Center)
      .width('100%')

      Row()
        .width('100%')
        .height(2)
        .backgroundColor('#B45309')
        .borderRadius(2)

      Text(this.previewData.summary)
        .fontSize(13)
        .fontColor('#374151')
        .lineHeight(20)
        .width('100%')

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.previewData.mainSections, (section: ResumePreviewSection) => {
          Column({ space: 5 }) {
            Text(section.title)
              .fontSize(13)
              .fontWeight(FontWeight.Bold)
              .fontColor('#92400E')
            Text(section.content)
              .fontSize(12)
              .fontColor('#1F2937')
              .lineHeight(19)
              .width('100%')
          }
          .alignItems(HorizontalAlign.Start)
          .width('48%')
          .padding(10)
          .borderRadius(12)
          .backgroundColor('#FFFBEB')
          .border({ width: 1, color: '#FDE68A' })
          .margin({ right: '2%', bottom: 10 })
        }, (section: ResumePreviewSection) => section.title)
      }
      .width('100%')
    }
    .width('100%')
    .padding(18)
    .borderRadius(16)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#D4AF37' })
  }

  @Builder
  private minimalResumePreview() {
    Column({ space: 16 }) {
      Column({ space: 5 }) {
        Text(this.previewData.name)
          .fontSize(30)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827')
        Text(this.previewData.targetPosition)
          .fontSize(14)
          .fontColor('#4B5563')
        Text(`${this.previewData.phone} \uFF5C ${this.previewData.email}`)
          .fontSize(11)
          .fontColor('#6B7280')
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')

      Divider().strokeWidth(1).color('#E5E7EB')

      Text(this.previewData.summary)
        .fontSize(13)
        .fontColor('#4B5563')
        .lineHeight(20)
        .width('100%')

      ForEach(this.previewData.mainSections, (section: ResumePreviewSection) => {
        Column({ space: 6 }) {
          Text(section.title)
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#374151')
          Text(section.content)
            .fontSize(13)
            .fontColor('#4B5563')
            .lineHeight(20)
            .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('100%')
      }, (section: ResumePreviewSection) => section.title)
    }
    .width('100%')
    .padding(20)
    .borderRadius(12)
    .backgroundColor('#FFFFFF')
    .border({ width: 1, color: '#D1D5DB' })
  }

  @Builder
  private blackGoldResumePreview() {
    Column({ space: 0 }) {
      Column({ space: 0 }) {
        Row({ space: 12 }) {
          this.photoBox(62, 31)
          Column({ space: 4 }) {
            Text(this.previewData.name)
              .fontSize(28)
              .fontWeight(FontWeight.Bold)
              .fontColor('#F9FAFB')
            Text(this.previewData.targetPosition)
              .fontSize(13)
              .fontColor('#FCD34D')
            Text(`${this.previewData.phone} \uFF5C ${this.previewData.email}`)
              .fontSize(11)
              .fontColor('#D1D5DB')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)
        }
        .width('100%')
      }
      .width('100%')
      .padding(14)
      .backgroundColor('#111827')

      Row() {
        Column({ space: 12 }) {
          ForEach(this.previewData.sidebarSections, (section: ResumePreviewSection) => {
            if (section.title !== 'SKILLS') {
              Column({ space: 3 }) {
                Text(section.title)
                  .fontSize(11)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#D4AF37')
                Text(section.content)
                  .fontSize(10)
                  .fontColor('#D1D5DB')
                  .lineHeight(15)
                  .width('100%')
              }
              .alignItems(HorizontalAlign.Start)
              .width('100%')
            }
          }, (section: ResumePreviewSection) => section.title)

          Text('SKILLS')
            .fontSize(11)
            .fontWeight(FontWeight.Bold)
            .fontColor('#D4AF37')
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.previewData.skillTags, (tag: string) => {
              Text(tag)
                .fontSize(10)
                .fontColor('#111827')
                .padding({ left: 7, right: 7, top: 4, bottom: 4 })
                .margin({ right: 5, bottom: 5 })
                .borderRadius(10)
                .backgroundColor('#FCD34D')
            }, (tag: string) => tag)
          }
          .width('100%')
        }
        .alignItems(HorizontalAlign.Start)
        .width('35%')
        .padding(14)

        Column()
          .width(1)
          .backgroundColor('rgba(212,175,55,0.3)')

        Column({ space: 12 }) {
          ForEach(this.previewData.mainSections, (section: ResumePreviewSection) => {
            Column({ space: 4 }) {
              Text(section.title)
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor('#D4AF37')
              Text(section.content)
                .fontSize(12)
                .fontColor('#D1D5DB')
                .lineHeight(18)
                .width('100%')
            }
            .alignItems(HorizontalAlign.Start)
            .width('100%')
          }, (section: ResumePreviewSection) => section.title)
        }
        .layoutWeight(1)
        .padding(14)
      }
      .width('100%')
      .backgroundColor('#1F2937')
    }
    .width('100%')
    .borderRadius(16)
    .clip(true)
    .border({ width: 1, color: '#D4AF37' })
  }

  @Builder
  private resumePreviewCard() {
    if (this.selectedTemplate === ResumeTemplateType.STANDARD) {
      this.standardResumePreview()
    } else if (this.selectedTemplate === ResumeTemplateType.CAMPUS) {
      this.campusResumePreview()
    } else if (this.selectedTemplate === ResumeTemplateType.EXECUTIVE) {
      this.executiveResumePreview()
    } else if (this.selectedTemplate === ResumeTemplateType.MINIMAL) {
      this.minimalResumePreview()
    } else if (this.selectedTemplate === ResumeTemplateType.BLACK_GOLD) {
      this.blackGoldResumePreview()
    } else {
      this.technicalResumePreview()
    }
  }

  build() {
    Scroll() {
      Column({ space: 18 }) {
        this.heroPanel()

        Column({ space: 12 }) {
          this.sectionTitle('候选人信息', '带 * 的字段用于生成和评分，信息越完整结果越好。')
          this.singleLineInput('姓名', this.candidateName, '例如：李明', true, (value: string) => {
            this.candidateName = value;
          })
          Column({ space: 8 }) {
            this.fieldLabel('证件照/头像', false)
            Row({ space: 12 }) {
              if (this.photoUri.length > 0) {
                if (this.isDemoPhoto(this.photoUri)) {
                  Image($r('app.media.startIcon'))
                    .width(76)
                    .height(92)
                    .borderRadius(10)
                    .objectFit(ImageFit.Cover)
                    .border({ width: 1, color: PRIMARY_BORDER })
                } else {
                  Image(this.photoUri)
                    .width(76)
                    .height(92)
                    .borderRadius(10)
                    .objectFit(ImageFit.Cover)
                    .border({ width: 1, color: PRIMARY_BORDER })
                }
              } else {
                Column({ space: 4 }) {
                  Text('照片')
                    .fontSize(14)
                    .fontWeight(FontWeight.Medium)
                    .fontColor('#98A2B3')
                  Text('未选择')
                    .fontSize(11)
                    .fontColor('#98A2B3')
                }
                .justifyContent(FlexAlign.Center)
                .width(76)
                .height(92)
                .borderRadius(10)
                .backgroundColor(PRIMARY_LIGHT)
                .border({ width: 1, color: PRIMARY_BORDER })
              }
              Column({ space: 8 }) {
                Text(this.photoUri.length > 0 ? '已选择照片' : '还没有选择照片')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#344054')
                Text(this.photoUri.length > 0 ? '照片会显示在简历预览中' : '请选择一张证件照，显示在简历预览中')
                  .fontSize(12)
                  .fontColor('#667085')
                  .lineHeight(18)
                  .width('100%')
                Row({ space: 8 }) {
                  Button('选择照片')
                    .height(36)
                    .fontSize(13)
                    .fontColor(PRIMARY_DARK)
                    .backgroundColor('#E0E7FF')
                    .borderRadius(10)
                    .layoutWeight(1)
                    .scale({ x: this.getInteractiveButtonScale('photo-select'), y: this.getInteractiveButtonScale('photo-select') })
                    .animation({ duration: 120, curve: Curve.EaseOut })
                    .onHover((isHover: boolean) => {
                      this.handleButtonHover('photo-select', isHover);
                    })
                    .onTouch((event: TouchEvent) => {
                      this.handleButtonTouch('photo-select', event);
                    })
                    .onClick(() => {
                      this.selectPhoto();
                    })
                  Button('清除')
                    .height(36)
                    .fontSize(13)
                    .fontColor('#475467')
                    .backgroundColor('#F1F5F9')
                    .borderRadius(10)
                    .width(68)
                    .enabled(this.photoUri.length > 0)
                    .scale({ x: this.getInteractiveButtonScale('photo-clear'), y: this.getInteractiveButtonScale('photo-clear') })
                    .animation({ duration: 120, curve: Curve.EaseOut })
                    .onHover((isHover: boolean) => {
                      this.handleButtonHover('photo-clear', isHover);
                    })
                    .onTouch((event: TouchEvent) => {
                      this.handleButtonTouch('photo-clear', event);
                    })
                    .onClick(() => {
                      this.clearPhoto();
                    })
                }
                .width('100%')
              }
              .layoutWeight(1)
              .alignItems(HorizontalAlign.Start)
            }
            .width('100%')
            .padding(10)
            .borderRadius(12)
            .backgroundColor('#F8FAFF')
            .border({ width: 1, color: BORDER_DEFAULT })
          }
          .width('100%')
          this.singleLineInput('联系电话', this.phone, '例如：13800000000', false, (value: string) => {
            this.phone = value;
          })
          this.singleLineInput('邮箱', this.email, '例如：liming@example.com', false, (value: string) => {
            this.email = value;
          })
          this.singleLineInput('教育经历', this.education, '学校、专业、学历', true, (value: string) => {
            this.education = value;
          })
          this.singleLineInput('求职岗位', this.targetPosition, '例如：HarmonyOS 应用开发工程师', true, (value: string) => {
            this.targetPosition = value;
          })
          this.multiLineInput('技能关键词', this.skills, '例如：ArkTS、ArkUI、Python、MySQL', false, (value: string) => {
            this.skills = value;
          })
          this.multiLineInput('工作/实习经历', this.workExperience, '填写真实经历，没有实习可写课程实践。', false, (value: string) => {
            this.workExperience = value;
          })
          this.multiLineInput('项目经历', this.projectExperience, '项目名称、个人职责、真实结果。', true, (value: string) => {
            this.projectExperience = value;
          })
          this.multiLineInput('自我评价', this.selfEvaluation, '学习能力、协作能力、职业态度。', false, (value: string) => {
            this.selfEvaluation = value;
          })
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: BORDER_DEFAULT })

        Column({ space: 12 }) {
          this.sectionTitle('模板选择', PROMPT_EXPLANATION)
          this.templateSelector()
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: BORDER_DEFAULT })

        if (this.errorMessage.length > 0) {
          Text(this.errorMessage)
            .fontSize(14)
            .fontColor('#B42318')
            .padding(12)
            .width('100%')
            .borderRadius(12)
            .backgroundColor('#FEF3F2')
            .border({ width: 1, color: '#FECDCA' })
        }

        if (this.apiErrorMessage.length > 0) {
          Text(this.apiErrorMessage)
            .fontSize(13)
            .fontColor('#92400E')
            .padding(12)
            .width('100%')
            .borderRadius(12)
            .backgroundColor('#FFFBEB')
            .border({ width: 1, color: '#FDE68A' })
        }

        Row({ space: 10 }) {
          Button('填充演示数据')
            .height(44)
            .fontSize(15)
            .fontColor(PRIMARY_DARK)
            .backgroundColor('#E0E7FF')
            .layoutWeight(1)
            .borderRadius(12)
            .scale({ x: this.getInteractiveButtonScale('demo-fill'), y: this.getInteractiveButtonScale('demo-fill') })
            .animation({ duration: 120, curve: Curve.EaseOut })
            .onHover((isHover: boolean) => {
              this.handleButtonHover('demo-fill', isHover);
            })
            .onTouch((event: TouchEvent) => {
              this.handleButtonTouch('demo-fill', event);
            })
            .onClick(() => {
              this.applyDemoData();
            })
          Button(this.isGenerating ? '生成中...' : '生成简历')
            .height(44)
            .fontSize(15)
            .fontColor('#FFFFFF')
            .backgroundColor(PRIMARY)
            .layoutWeight(1)
            .borderRadius(12)
            .enabled(!this.isGenerating)
            .scale({ x: this.getInteractiveButtonScale('resume-generate'), y: this.getInteractiveButtonScale('resume-generate') })
            .animation({ duration: 120, curve: Curve.EaseOut })
            .onHover((isHover: boolean) => {
              this.handleButtonHover('resume-generate', isHover);
            })
            .onTouch((event: TouchEvent) => {
              this.handleButtonTouch('resume-generate', event);
            })
            .onClick(() => {
              this.generateResume();
            })
        }
        .width('100%')

        Column({ space: 12 }) {
          this.sectionTitle('模板预览', '生成后会把信息填入现代简历模板，下面仍保留纯文本编辑。')
          if (this.generatedResume.length > 0) {
            this.resumePreviewCard()
          } else {
            Text('点击"生成简历"后，这里会显示带版式的简历预览。')
              .fontSize(14)
              .fontColor('#5B6475')
              .padding(14)
              .width('100%')
              .borderRadius(12)
              .backgroundColor('#F8FAFF')
              .border({ width: 1, color: BORDER_DEFAULT })
          }
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: BORDER_DEFAULT })

        Column({ space: 12 }) {
          this.sectionTitle('在线编辑', '这里保留纯文本简历，方便复制、修改和后续接入 PDF 导出。')
          TextArea({ text: this.editedResume, placeholder: '点击"生成简历"后，这里会显示可编辑简历。' })
            .height(260)
            .fontSize(14)
            .lineHeight(22)
            .fontColor('#111827')
            .backgroundColor(PRIMARY_LIGHT)
            .borderRadius(12)
            .border({ width: 1, color: BORDER_DEFAULT })
            .onChange((value: string) => {
              this.editedResume = value;
              this.exportStatus = '';
            })

          Row({ space: 10 }) {
            Button(this.isScoring ? '评分中...' : '更新评分')
              .height(42)
              .fontSize(14)
              .fontColor(PRIMARY_DARK)
              .backgroundColor('#E0E7FF')
              .layoutWeight(1)
              .borderRadius(12)
              .enabled(!this.isScoring)
              .scale({ x: this.getInteractiveButtonScale('score-refresh'), y: this.getInteractiveButtonScale('score-refresh') })
              .animation({ duration: 120, curve: Curve.EaseOut })
              .onHover((isHover: boolean) => {
                this.handleButtonHover('score-refresh', isHover);
              })
              .onTouch((event: TouchEvent) => {
                this.handleButtonTouch('score-refresh', event);
              })
              .onClick(() => {
                this.refreshScore();
              })
            Button(this.isExporting ? '导出中...' : '导出 PDF')
              .height(42)
              .fontSize(14)
              .fontColor('#FFFFFF')
              .backgroundColor('#059669')
              .layoutWeight(1)
              .borderRadius(12)
              .enabled(!this.isExporting)
              .scale({ x: this.getInteractiveButtonScale('pdf-export'), y: this.getInteractiveButtonScale('pdf-export') })
              .animation({ duration: 120, curve: Curve.EaseOut })
              .onHover((isHover: boolean) => {
                this.handleButtonHover('pdf-export', isHover);
              })
              .onTouch((event: TouchEvent) => {
                this.handleButtonTouch('pdf-export', event);
              })
              .onClick(() => {
                this.exportPdf();
              })
          }
          .width('100%')

          if (this.exportStatus.length > 0) {
            Text(this.exportStatus)
              .fontSize(13)
              .fontColor('#166534')
              .padding(10)
              .width('100%')
              .borderRadius(12)
              .backgroundColor('#DCFCE7')
              .border({ width: 1, color: '#86EFAC' })
          }
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: BORDER_DEFAULT })

        this.scorePanel()
      }
      .width('100%')
      .padding(16)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG_PAGE)
  }
}
