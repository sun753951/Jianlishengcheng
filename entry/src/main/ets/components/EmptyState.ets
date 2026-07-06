/**
 * 空状态组件 — 无数据时的友好占位提示
 */

@Component
export struct EmptyState {
  @Prop icon: string = '📄';
  @Prop title: string = '暂无数据';
  @Prop description: string = '';
  onAction: () => void = () => {};
  @Prop actionText: string = '';

  build() {
    Column() {
      Text(this.icon)
        .fontSize(64)

      Text(this.title)
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#4B5563')
        .margin({ top: 16 })

      if (this.description.length > 0) {
        Text(this.description)
          .fontSize(13)
          .fontColor('#9CA3AF')
          .textAlign(TextAlign.Center)
          .margin({ top: 8, left: 32, right: 32 })
          .maxLines(3)
      }

      if (this.actionText.length > 0) {
        Button(this.actionText)
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#1A56DB')
          .borderRadius(8)
          .margin({ top: 20 })
          .padding({ left: 24, right: 24 })
          .onClick(() => {
            if (this.onAction !== undefined) {
              this.onAction();
            }
          })
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .padding({ left: 32, right: 32 })
  }
}
