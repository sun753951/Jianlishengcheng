/**
 * Dashboard — 首页仪表盘，展示已有简历列表和新建入口
 */
import router from '@ohos.router';
import { ResumeData, ResumeGenerateStatus } from '../model/ResumeData';
import { SampleData } from '../utils/SampleData';
import { ResumeCard } from '../components/ResumeCard';
import { EmptyState } from '../components/EmptyState';

@Entry
@Component
struct Index {
  @State resumeList: ResumeData[] = [];
  @State isLoading: boolean = true;

  aboutToAppear(): void {
    // 加载示例简历数据
    this.loadResumes();
  }

  loadResumes(): void {
    // 模拟加载已有简历列表
    const sampleResume: ResumeData = SampleData.getSampleResume();
    this.resumeList = [sampleResume];
    this.isLoading = false;
  }

  build() {
    Column() {
      // 顶部导航栏
      Row() {
        Text('智能简历')
          .fontSize(22)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Blank()

        Text('帮助')
          .fontSize(14)
          .fontColor('#1A56DB')
      }
      .width('100%')
      .padding({ left: 20, right: 20, top: 16, bottom: 12 })

      // 内容区域
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(36)
            .height(36)
            .color('#1A56DB')
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else if (this.resumeList.length === 0) {
        // 空状态
        Column() {
          EmptyState({
            icon: '📋',
            title: '还没有简历',
            description: '使用AI智能生成您的第一份精美简历',
            actionText: '创建简历',
            onAction: () => {
              this.navigateToTemplatePicker();
            }
          })
        }
        .width('100%')
        .layoutWeight(1)
      } else {
        // 简历列表
        Scroll() {
          Column() {
            ForEach(this.resumeList, (resume: ResumeData, index: number) => {
              ResumeCard({
                resume: resume,
                onCardClick: () => {
                  this.navigateToPreview(resume);
                }
              })
              .margin({ bottom: 12 })
            }, (resume: ResumeData, index: number) => resume.id + index.toString())
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 8, bottom: 80 })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  navigateToTemplatePicker(): void {
    router.pushUrl({ url: 'pages/TemplatePicker' });
  }

  navigateToPreview(resume: ResumeData): void {
    AppStorage.setOrCreate<ResumeData>('currentResume', resume);
    router.pushUrl({ url: 'pages/ResumePreview' });
  }
}
