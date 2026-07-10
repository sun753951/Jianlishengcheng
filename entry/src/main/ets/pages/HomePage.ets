import router from '@ohos.router';
import { ResumeDataHolder } from '../model/ResumeModels';
import { BG_PAGE, PRIMARY, PRIMARY_BORDER, PRIMARY_LIGHT, RADIUS_MD, RADIUS_LG } from '../style/Colors';

@Entry
@Component
struct HomePage {
  build() {
    Column() {
      // 品牌渐变装饰条
      Row()
        .height(4)
        .width('100%')
        .backgroundColor(PRIMARY);

      Column({ space: 16 }) {
        Image($r('app.media.startIcon'))
          .width(80)
          .height(80)
          .borderRadius(20)
          .objectFit(ImageFit.Cover);

        Text('智能简历生成系统')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#111827');

        Text('6 套模板')
          .fontSize(14)
          .fontColor('#6B7280')
          .textAlign(TextAlign.Center);
      }
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 80 });

      // 特性卡片
      Row({ space: 10 }) {
        Column({ space: 6 }) {
          Text('\uD83E\uDDE0')
            .fontSize(28);
          Text('AI 智能生成')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827');
          Text('填写关键信息，AI 自动生成专业简历内容')
            .fontSize(11)
            .fontColor('#6B7280')
            .textAlign(TextAlign.Center)
            .lineHeight(16);
        }
        .layoutWeight(1)
        .padding(14)
        .borderRadius(RADIUS_MD)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: PRIMARY_BORDER });

        Column({ space: 6 }) {
          Text('\uD83C\uDFA8')
            .fontSize(28);
          Text('6 套精选模板')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827');
          Text('标准/技术/校园/商务/极简/黑金，一键切换')
            .fontSize(11)
            .fontColor('#6B7280')
            .textAlign(TextAlign.Center)
            .lineHeight(16);
        }
        .layoutWeight(1)
        .padding(14)
        .borderRadius(RADIUS_MD)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: PRIMARY_BORDER });

        Column({ space: 6 }) {
          Text('\uD83D\uDCC4')
            .fontSize(28);
          Text('一键导出 PDF')
            .fontSize(13)
            .fontWeight(FontWeight.Bold)
            .fontColor('#111827');
          Text('支持本地保存与 PC 端下载')
            .fontSize(11)
            .fontColor('#6B7280')
            .textAlign(TextAlign.Center)
            .lineHeight(16);
        }
        .layoutWeight(1)
        .padding(14)
        .borderRadius(RADIUS_MD)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: PRIMARY_BORDER });
      }
      .width('100%')
      .margin({ top: 32, left: 24, right: 24 });

      Blank();

      Button('开始制作简历')
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')
        .width('100%')
        .height(52)
        .borderRadius(RADIUS_LG)
        .backgroundColor(PRIMARY)
        .shadow({ radius: 12, color: 'rgba(79,70,229,0.25)', offsetY: 4 })
        .onClick(() => {
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
    .backgroundColor(BG_PAGE);
  }
}
