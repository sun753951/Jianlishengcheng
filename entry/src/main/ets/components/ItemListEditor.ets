/**
 * 通用多条目列表编辑器 — 支持添加/删除，通过 @BuilderParam 插槽自定义每条目内容
 */
@Component
export struct ItemListEditor {
  @Prop itemTypeLabel: string = '';
  @Prop emptyHint: string = '暂无数据，点击下方按钮添加';
  @Prop itemCount: number = 0;
  onAddItem: () => void = () => {};
  onDeleteItem: (index: number) => void = (index: number) => {};
  @BuilderParam itemBuilder: (index: number) => void = this.defaultItemBuilder;

  build() {
    Column() {
      // 条目列表
      if (this.itemCount === 0) {
        Text(this.emptyHint)
          .fontSize(13)
          .fontColor('#9CA3AF')
          .width('100%')
          .textAlign(TextAlign.Center)
          .padding({ top: 20, bottom: 20 })
      } else {
        ForEach(this.buildIndexArray(), (index: number) => {
          Column() {
            // 条目内容区
            Column() {
              this.itemBuilder(index)
            }
            .width('100%')
            .layoutWeight(1)

            // 删除按钮
            Row() {
              Blank()
              Text('删除')
                .fontSize(12)
                .fontColor('#EF4444')
                .padding({ left: 12, right: 12, top: 4, bottom: 4 })
                .stateStyles({
                  pressed: { .backgroundColor('#DC2626').opacity(0.85) }
                })
                .onClick(() => {
                  this.onDeleteItem(index);
                })
            }
            .width('100%')
            .margin({ top: 4 })
          }
          .width('100%')
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
          .padding(12)
          .margin({ bottom: 8 })
        }, (item: number) => item.toString())
      }

      // 添加按钮
      Button('+ 添加' + this.itemTypeLabel)
        .fontSize(13)
        .fontColor('#1A56DB')
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: '#D1D5DB', style: BorderStyle.Dashed })
        .borderRadius(8)
        .padding(12)
        .width('100%')
        .stateStyles({
          pressed: { .opacity(0.7) }
        })
        .onClick(() => {
          this.onAddItem();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  defaultItemBuilder(index: number) {
  }

  private buildIndexArray(): number[] {
    const result: number[] = [];
    for (let i: number = 0; i < this.itemCount; i++) {
      result.push(i);
    }
    return result;
  }
}
