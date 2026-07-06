/**
 * 可折叠模块组件 — 通用的折叠卡片，用于简历编辑器中各模块的展开/折叠
 */
@Component
export struct CollapsibleSection {
  @Prop sectionTitle: string = '';
  @Prop itemCount: number = 0;
  @Prop defaultExpanded: boolean = false;
  @BuilderParam childContent: () => void = this.defaultContent;

  @State isExpanded: boolean = false;

  aboutToAppear(): void {
    this.isExpanded = this.defaultExpanded;
  }

  build() {
    Column() {
      // 标题栏
      Row() {
        Text((this.isExpanded ? '▼' : '▶') + ' ' + this.sectionTitle)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .layoutWeight(1)

        if (this.itemCount > 0) {
          Text('(' + this.itemCount.toString() + ')')
            .fontSize(12)
            .fontColor('#9CA3AF')
        }
      }
      .width('100%')
      .padding(16)
      .stateStyles({
        pressed: { .backgroundColor('#F3F4F6') }
      })
      .onClick(() => {
        this.isExpanded = !this.isExpanded;
      })

      // 分隔线
      Divider()
        .width('100%')
        .height(1)
        .color('#F3F4F6')

      // 内容区 — 条件渲染带展开动画
      if (this.isExpanded) {
        Column() {
          this.childContent()
        }
        .width('100%')
        .padding(16)
        .animation({ duration: 200, curve: Curve.EaseInOut })
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .margin({ left: 12, right: 12, top: 8 })
  }

  @Builder
  defaultContent() {
  }
}
