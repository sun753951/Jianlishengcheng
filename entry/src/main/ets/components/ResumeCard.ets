/**
 * 简历卡片组件 — 用于列表展示简历摘要
 */
import { ResumeData } from '../model/ResumeData';

@Component
export struct ResumeCard {
  @Prop resume: ResumeData = new ResumeData();
  onCardClick: () => void = () => {};

  build() {
    Column() {
      // 顶部色条
      Row()
        .width('100%')
        .height(4)
        .backgroundColor(this.getThemeColor())

      // 卡片内容
      Column() {
        // 头像 + 姓名 + 职位
        Row() {
          // 头像占位
          Circle()
            .width(48)
            .height(48)
            .fill('#E5E7EB')

          Column() {
            Text(this.resume.personalInfo.name || '未命名简历')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#1A1A1A')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })

            Text(this.resume.personalInfo.title || '未设置职位')
              .fontSize(13)
              .fontColor('#6B7280')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .margin({ top: 2 })
          }
          .alignItems(HorizontalAlign.Start)
          .margin({ left: 12 })
          .layoutWeight(1)
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
        .padding({ top: 12, left: 12, right: 12 })

        // 更新时间和摘要
        Text(this.getUpdateTime())
          .fontSize(12)
          .fontColor('#9CA3AF')
          .margin({ top: 8, left: 12, right: 12 })

        Text(this.resume.personalInfo.summary)
          .fontSize(13)
          .fontColor('#4B5563')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 6, left: 12, right: 12, bottom: 12 })
          .width('100%')
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#00000015',
      offsetX: 0,
      offsetY: 2
    })
    .onClick(() => {
      if (this.onCardClick !== undefined) {
        this.onCardClick();
      }
    })
  }

  getThemeColor(): ResourceColor {
    if (this.resume.colorScheme === 'green') {
      return '#059669';
    }
    if (this.resume.colorScheme === 'dark') {
      return '#111827';
    }
    return '#1A56DB';
  }

  getUpdateTime(): string {
    if (this.resume.updatedAt.length > 0) {
      return '更新于 ' + this.resume.updatedAt;
    }
    return '新建简历';
  }
}
