/**
 * EditableStringList — 字符串列表增删改组件
 * 用于成就列表、项目亮点列表、技术栈列表等
 */
@Component
export struct EditableStringList {
  @Prop @Watch('onItemsChanged') items: string[] = [];
  @Prop placeholder: string = '输入内容';
  @Prop addButtonText: string = '+ 添加';

  onChange: (items: string[]) => void = () => {};

  onItemsChanged(propName: string): void {
    console.log(`[DEBUG][H4] @Prop items changed | len=${this.items.length} | ts=${Date.now()}`);
  }

  build() {
    Column() {
      ForEach(this.items, (item: string, index: number) => {
        Row() {
          TextInput({ placeholder: this.placeholder, text: item })
            .layoutWeight(1)
            .backgroundColor('#F9FAFB')
            .borderRadius(8)
            .border({ width: 1, color: '#E5E7EB' })
            .padding({ left: 10, right: 10, top: 6, bottom: 6 })
            .fontSize(13)
            .onChange((value: string) => {
              const newItems: string[] = [];
              for (let i = 0; i < this.items.length; i++) {
                if (i === index) {
                  newItems.push(value);
                } else {
                  newItems.push(this.items[i]);
                }
              }
              this.onChange(newItems);
            })

          Text('✕')
            .fontSize(16)
            .fontColor('#EF4444')
            .width(32)
            .textAlign(TextAlign.Center)
            .onClick(() => {
              console.log(`[DEBUG][H1] ✕ clicked | index=${index} | itemsLen=${this.items.length} | ts=${Date.now()}`);
              const newItems: string[] = [];
              for (let i = 0; i < this.items.length; i++) {
                if (i !== index) {
                  newItems.push(this.items[i]);
                }
              }
              console.log(`[DEBUG][H1] calling onChange | newItemsLen=${newItems.length} | ts=${Date.now()}`);
              this.onChange(newItems);
            })
        }
        .width('100%')
        .margin({ bottom: 8 })
      }, (item: string, index: number) => index.toString())

      Text(this.addButtonText)
        .fontSize(12)
        .fontColor('#1A56DB')
        .backgroundColor('#EBF4FF')
        .borderRadius(6)
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .onClick(() => {
          console.log(`[DEBUG][H1] add clicked | itemsLen=${this.items.length} | ts=${Date.now()}`);
          const newItems: string[] = [];
          for (let i = 0; i < this.items.length; i++) {
            newItems.push(this.items[i]);
          }
          newItems.push('');
          console.log(`[DEBUG][H1] calling onChange add | newItemsLen=${newItems.length} | ts=${Date.now()}`);
          this.onChange(newItems);
        })
    }
    .width('100%')
  }
}
