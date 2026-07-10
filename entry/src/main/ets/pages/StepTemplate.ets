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
import { PRIMARY, PRIMARY_LIGHT, BG_PAGE, BORDER_DEFAULT, PRIMARY_BORDER } from '../style/Colors';

@Entry
@Component
struct StepTemplate {
  @State selectedTemplate: ResumeTemplateType = ResumeDataHolder.getInstance().selectedTemplate;
  @State isGenerating: boolean = false;
  @State errorMessage: string = '';

  private getTemplateColor(type: ResumeTemplateType): string {
    if (type === ResumeTemplateType.STANDARD) { return '#0F766E'; }
    if (type === ResumeTemplateType.TECHNICAL) { return '#1E3A8A'; }
    if (type === ResumeTemplateType.CAMPUS) { return '#7C3AED'; }
    if (type === ResumeTemplateType.EXECUTIVE) { return '#B45309'; }
    if (type === ResumeTemplateType.MINIMAL) { return '#6B7280'; }
    if (type === ResumeTemplateType.BLACK_GOLD) { return '#111827'; }
    return '#0F766E';
  }

  @Builder
  private stepIndicator(current: number) {
    Row({ space: 0 }) {
      ForEach([1, 2, 3, 4], (step: number, index: number) => {
        Row({ space: 0 }) {
          Column({ space: 2 }) {
            Column() {
              if (step < current) {
                Text('\u2713')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF');
              } else {
                Text(`${step}`)
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(step === current ? '#FFFFFF' : '#9CA3AF');
              }
            }
            .width(24)
            .height(24)
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(step <= current ? PRIMARY : '#E5E7EB');
            Text(step === 1 ? '基本信息' : step === 2 ? '经历' : step === 3 ? '模板' : '预览')
              .fontSize(9)
              .fontColor(step <= current ? PRIMARY : '#9CA3AF');
          }
          .alignItems(HorizontalAlign.Center);

          if (index < 3) {
            Divider()
              .width(24)
              .height(1)
              .color(step < current ? PRIMARY : '#E5E7EB')
              .margin({ top: -8 });
          }
        }
      });
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .padding({ top: 8, bottom: 8 });
  }

  @Builder
  private templateCard(option: TemplateOption) {
    Column({ space: 0 }) {
      // 颜色预览块
      Row()
        .width('100%')
        .height(40)
        .borderRadius({ topLeft: 12, topRight: 12 })
        .backgroundColor(this.getTemplateColor(option.templateType));

      // 信息区
      Column({ space: 4 }) {
        Text(option.title)
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827');
        Text(option.description)
          .fontSize(11)
          .fontColor('#6B7280')
          .textAlign(TextAlign.Center);
      }
      .padding(10);
    }
    .width('48%')
    .borderRadius(12)
    .backgroundColor(this.selectedTemplate === option.templateType ? PRIMARY_LIGHT : '#FFFFFF')
    .border({
      width: this.selectedTemplate === option.templateType ? 2 : 1,
      color: this.selectedTemplate === option.templateType ? PRIMARY : BORDER_DEFAULT
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
            Flex({ wrap: FlexWrap.Wrap }) {
              ForEach(TEMPLATE_OPTIONS, (option: TemplateOption) => {
                this.templateCard(option);
              });
            }
            .width('100%');
          }
          .width('100%')
          .padding(16)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: BORDER_DEFAULT });

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
        Button('\u2190 上一步')
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

        Button(this.isGenerating ? '生成中...' : '生成简历 \u2192')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .height(48)
          .borderRadius(12)
          .backgroundColor(this.isGenerating ? '#A5B4FC' : PRIMARY)
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
    .backgroundColor(BG_PAGE);
  }
}
