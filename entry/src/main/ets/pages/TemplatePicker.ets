/**
 * TemplatePicker — 模板选择页面
 */
import router from '@ohos.router';
import { TemplateConfig, TemplatePreset } from '../model/TemplateConfig';
import { TemplateItem } from '../components/TemplateItem';

@Entry
@Component
struct TemplatePicker {
  @State templates: TemplateConfig[] = TemplatePreset.getPresets();
  @State selectedTemplateId: string = '';

  build() {
    Column() {
      // 顶部标题栏
      Row() {
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })

        Text('选择模板')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .margin({ left: 12 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })

      // 说明文字
      Text('选择一个适合您的简历模板')
        .fontSize(14)
        .fontColor('#6B7280')
        .width('100%')
        .padding({ left: 16, right: 16, bottom: 12 })

      // 模板列表
      Scroll() {
        Column() {
          ForEach(this.templates, (template: TemplateConfig, index: number) => {
            TemplateItem({
              template: template,
              isSelected: this.selectedTemplateId === template.id,
              onSelect: () => {
                this.selectedTemplateId = template.id;
              }
            })
            .margin({ bottom: 16 })
          }, (template: TemplateConfig, index: number) => template.id + index.toString())
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 8, bottom: 100 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)

      // 底部确认按钮
      Button('下一步：填写信息')
        .fontSize(15)
        .fontColor('#FFFFFF')
        .backgroundColor(this.selectedTemplateId.length > 0 ? '#1A56DB' : '#B0C4DE')
        .borderRadius(10)
        .height(48)
        .width('90%')
        .margin({ bottom: 24 })
        .enabled(this.selectedTemplateId.length > 0)
        .onClick(() => {
          if (this.selectedTemplateId.length > 0) {
            this.proceedToForm();
          }
        })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  proceedToForm(): void {
    // 保存选中的模板ID
    AppStorage.setOrCreate<string>('selectedTemplateId', this.selectedTemplateId);
    router.pushUrl({ url: 'pages/ResumeForm' });
  }
}
