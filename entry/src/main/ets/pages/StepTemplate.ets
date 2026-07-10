import router from '@ohos.router';
import { TEMPLATE_OPTIONS } from '../constants/ResumeConstants';
import {
  ResumeDataHolder,
  ResumeTemplateType,
  TemplateOption
} from '../model/ResumeModels';
import {
  requestGenerateResume,
  GenerateResumeApiResponse
} from '../service/ResumeApiService';
import { generateResumePreview, generateResumeText } from '../service/ResumeService';

@Entry
@Component
struct StepTemplate {
  @State selectedTemplate: ResumeTemplateType = ResumeDataHolder.getInstance().selectedTemplate;
  @State isGenerating: boolean = false;
  @State errorMessage: string = '';

  @Builder
  private stepIndicator(current: number) {
    Row({ space: 8 }) {
      ForEach([1, 2, 3, 4], (step: number) => {
        Circle({ width: 10, height: 10 })
          .fill(step <= current ? '#2563EB' : '#D1D5DB');
      });
    }
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: 24 });
  }

  @Builder
  private templateCard(option: TemplateOption) {
    Column({ space: 8 }) {
      Text(option.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor(this.selectedTemplate === option.templateType ? '#FFFFFF' : '#111827');
      Text(option.description)
        .fontSize(12)
        .fontColor(this.selectedTemplate === option.templateType ? '#DBEAFE' : '#6B7280')
        .textAlign(TextAlign.Center);
    }
    .width('100%')
    .padding(14)
    .borderRadius(12)
    .backgroundColor(this.selectedTemplate === option.templateType ? '#2563EB' : '#F9FAFB')
    .border({
      width: this.selectedTemplate === option.templateType ? 2 : 1,
      color: this.selectedTemplate === option.templateType ? '#2563EB' : '#E5E7EB'
    })
    .onClick(() => {
      this.selectedTemplate = option.templateType;
      this.errorMessage = '';
    });
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          this.stepIndicator(3);

          Column({ space: 4 }) {
            Text('选择模板')
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#111827');
            Text('第 3 步 / 共 4 步 — 选择简历模板风格')
              .fontSize(13)
              .fontColor('#6B7280');
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .margin({ bottom: 8 });

          Column({ space: 10 }) {
            ForEach(TEMPLATE_OPTIONS, (option: TemplateOption) => {
              this.templateCard(option);
            });
          }
          .width('100%')
          .padding(16)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: '#DDE7FF' });

          if (this.errorMessage) {
            Text(this.errorMessage)
              .fontSize(13)
              .fontColor('#EF4444')
              .width('100%')
              .textAlign(TextAlign.Center)
              .padding(12)
              .borderRadius(10)
              .backgroundColor('#FEF2F2');
          }
        }
      }
      .layoutWeight(1);

      Row({ space: 12 }) {
        Button('← 上一步')
          .fontSize(15)
          .fontColor('#6B7280')
          .layoutWeight(1)
          .height(48)
          .borderRadius(12)
          .backgroundColor('#F3F4F6')
          .onClick(() => {
            ResumeDataHolder.getInstance().selectedTemplate = this.selectedTemplate;
            router.back();
          });

        Button(this.isGenerating ? '生成中...' : '生成简历 →')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .height(48)
          .borderRadius(12)
          .backgroundColor(this.isGenerating ? '#93C5FD' : '#2563EB')
          .enabled(!this.isGenerating)
          .onClick(async () => {
            const holder = ResumeDataHolder.getInstance();
            holder.selectedTemplate = this.selectedTemplate;

            this.isGenerating = true;
            this.errorMessage = '';

            try {
              const response: GenerateResumeApiResponse = await requestGenerateResume(
                holder.formData, this.selectedTemplate
              );
              holder.generatedResume = response.resumeText;
              holder.previewData = response.previewData;
              router.pushUrl({ url: 'pages/StepPreview' });
            } catch (_error) {
              // Fallback: local generation
              const localText = generateResumeText(holder.formData, this.selectedTemplate);
              const localPreview = generateResumePreview(holder.formData, this.selectedTemplate);
              holder.generatedResume = localText;
              holder.previewData = localPreview;
              this.errorMessage = 'AI 服务不可用，已使用本地演示生成';
              router.pushUrl({ url: 'pages/StepPreview' });
            } finally {
              this.isGenerating = false;
            }
          });
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF');
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F8FAFC');
  }
}