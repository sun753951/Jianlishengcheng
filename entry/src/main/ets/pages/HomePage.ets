import router from '@ohos.router';
import { ResumeDataHolder } from '../model/ResumeModels';

@Entry
@Component
struct HomePage {
  build() {
    Column() {
      Column({ space: 16 }) {
        Image($r('app.media.startIcon'))
          .width(80)
          .height(80)
          .borderRadius(20)
          .objectFit(ImageFit.Cover);

        Text('智能简历生成系统')
          .fontSize(26)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827');

        Text('6 步完成 · 3 套模板 · 实时预览 · PDF 导出')
          .fontSize(14)
          .fontColor('#6B7280')
          .textAlign(TextAlign.Center);
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 120 });

      Blank();

      Button('开始制作简历')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .width('100%')
        .height(52)
        .borderRadius(14)
        .backgroundColor('#2563EB')
        .onClick(() => {
          // 每次从首页进入，清空上一轮数据
          ResumeDataHolder.getInstance().reset();
          router.pushUrl({ url: 'pages/StepBasicInfo' });
        });

      Text('基于 AI 驱动，只需填写关键信息即可生成专业简历')
        .fontSize(12)
        .fontColor('#9CA3AF')
        .textAlign(TextAlign.Center)
        .margin({ top: 12, bottom: 40 });
    }
    .width('100%')
    .height('100%')
    .padding({ left: 24, right: 24 })
    .backgroundColor('#F8FAFC');
  }
}