/**
 * Generating — 简历生成中页面，显示AI处理动画
 */
import router from '@ohos.router';
import { ResumeData } from '../model/ResumeData';
import { MockGenerator, ProgressCallback } from '../utils/MockGenerator';

@Entry
@Component
struct Generating {
  @State progress: number = 0;
  @State statusMessage: string = '正在准备...';
  @State currentTipIndex: number = 0;
  @State isComplete: boolean = false;

  private tipMessages: string[] = [
    '好的简历排版能提升面试官的第一印象',
    '使用行动动词能让经历描述更有力',
    '量化成果能让简历更有说服力',
    '关键词优化能提升ATS通过率',
    '简历长度控制在1-2页最佳'
  ];

  aboutToAppear(): void {
    this.startGeneration();
    this.startTipRotation();
  }

  startGeneration(): void {
    const pendingResume: ResumeData | undefined = AppStorage.get<ResumeData>('pendingResume');
    const dataToGenerate: ResumeData = pendingResume !== undefined ? pendingResume : new ResumeData();

    const onProgress: ProgressCallback = (progress: number, message: string) => {
      this.progress = progress;
      this.statusMessage = message;
    };

    MockGenerator.generate(dataToGenerate, onProgress).then((result: ResumeData) => {
      AppStorage.setOrCreate<ResumeData>('currentResume', result);
      this.isComplete = true;
      setTimeout(() => {
        router.replaceUrl({ url: 'pages/ResumePreview' });
      }, 500);
    });
  }

  startTipRotation(): void {
    const timer = setInterval(() => {
      if (this.isComplete) {
        clearInterval(timer);
        return;
      }
      this.currentTipIndex = (this.currentTipIndex + 1) % this.tipMessages.length;
    }, 3000);
  }

  build() {
    Column() {
      // 顶部
      Row()
        .width('100%')
        .height(48)

      // 主要内容区
      Column() {
        // 动画图标
        Stack() {
          // 背景环
          Circle()
            .width(120)
            .height(120)
            .fill('#F0F5FF')
            .opacity(0.3)

          // 进度环
          Progress({
            value: this.progress,
            total: 100,
            type: ProgressType.Ring
          })
            .width(120)
            .height(120)
            .color('#1A56DB')
            .backgroundColor('#E5E7EB')

          // 中心图标
          if (this.isComplete) {
            Text('✅')
              .fontSize(40)
          } else {
            Text('🤖')
              .fontSize(40)
          }
        }

        // 进度百分比
        Text(this.progress.toString() + '%')
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A56DB')
          .margin({ top: 24 })
          .fontFamily('sans-serif')

        // 状态消息
        Text(this.statusMessage)
          .fontSize(15)
          .fontColor('#4B5563')
          .margin({ top: 12 })

        // 分割线
        Divider()
          .width('60%')
          .margin({ top: 32, bottom: 24 })

        // 小贴士
        Column() {
          Text('💡 简历小贴士')
            .fontSize(13)
            .fontColor('#9CA3AF')
            .margin({ bottom: 8 })

          Text(this.tipMessages[this.currentTipIndex])
            .fontSize(14)
            .fontColor('#6B7280')
            .textAlign(TextAlign.Center)
            .maxLines(2)
            .padding({ left: 24, right: 24 })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .layoutWeight(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#FFFFFF')
  }
}
