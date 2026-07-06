/**
 * EditableSectionCard — 可折叠卡片容器，用于包裹每个简历章节
 */
@Component
export struct EditableSectionCard {
  @Prop title: string = '';
  @Prop defaultExpanded: boolean = false;
  @Prop itemCount: number = 0;
  @Prop showAddButton: boolean = true;
  @Prop renderKey: number = 0;            // 父组件递增此值 → 强制本组件 build() 重新执行

  @BuilderParam content: () => void = this.emptyContent;

  @State isExpanded: boolean = false;

  onAddItem: () => void = () => {};

  aboutToAppear(): void {
    this.isExpanded = this.defaultExpanded;
  }

  @Builder
  emptyContent() {
  }

  build() {
    Column() {
      // 头部：点击切换折叠
      Row() {
        Text(this.isExpanded ? '▼' : '▶')
          .fontSize(12)
          .fontColor('#6B7280')
          .width(20)

        Text(this.title)
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        if (this.itemCount > 0) {
          Text(this.itemCount.toString())
            .fontSize(11)
            .fontColor('#FFFFFF')
            .backgroundColor('#1A56DB')
            .borderRadius(10)
            .padding({ left: 6, right: 6, top: 1, bottom: 1 })
            .margin({ left: 8 })
        }

        Blank()

        if (this.showAddButton) {
          Text('+ 添加')
            .fontSize(12)
            .fontColor('#1A56DB')
            .backgroundColor('#EBF4FF')
            .borderRadius(6)
            .padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .onClick(() => {
              this.onAddItem();
            })
        }
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .onClick(() => {
        this.isExpanded = !this.isExpanded;
      })

      // 内容区
      if (this.isExpanded) {
        Divider()
          .color('#F3F4F6')
          .width('100%')

        Column() {
          this.content()
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 16 })
      }
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(16)
    .margin({ left: 0, right: 0, top: 12, bottom: 0 })
    .shadow({
      radius: 8,
      color: '#00000010',
      offsetX: 0,
      offsetY: 2
    })
  }
}
