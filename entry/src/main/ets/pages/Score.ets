/**
 * Score — 简历评分页面（P1占位）
 */
import router from '@ohos.router';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
struct Score {
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

        Text('简历评分')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .margin({ left: 12 })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 12 })

      // 占位内容
      EmptyState({
        icon: '⭐',
        title: 'AI评分功能开发中',
        description: '基于AI的简历智能评分引擎正在开发中，将提供完整度、排版、内容质量等多维度评分。',
        actionText: '返回首页',
        onAction: () => {
          router.clear();
          router.pushUrl({ url: 'pages/Index' });
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }
}
