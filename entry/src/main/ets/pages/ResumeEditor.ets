/**
 * ResumeEditor — 简历编辑器（P1占位）
 */
import router from '@ohos.router';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
struct ResumeEditor {
  build() {
    Column() {
      // 顶部
      Row() {
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
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

      // 占位内容
      EmptyState({
        icon: '🚧',
        title: '编辑器开发中',
        description: '完整的简历编辑器正在开发中，敬请期待。您可以返回预览页面查看当前简历。',
        actionText: '返回预览',
        onAction: () => {
          router.back();
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
