/**
 * 模板选项组件 — 用于模板选择页面中展示单个模板
 */
import { TemplateConfig } from '../model/TemplateConfig';

@Component
export struct TemplateItem {
  @Prop template: TemplateConfig = new TemplateConfig();
  @Prop isSelected: boolean = false;
  onSelect: () => void = () => {};

  build() {
    Column() {
      // 模板缩略图占位
      Stack() {
        Row()
          .width('100%')
          .height(120)
          .backgroundColor(this.getBgColor())
          .borderRadius({ topLeft: 12, topRight: 12 })

        // 预览示意
        Column() {
          Row()
            .width('60%')
            .height(4)
            .backgroundColor(this.template.palette.primary)
            .borderRadius(2)

          ForEach([1, 2, 3], (item: number, _index: number) => {
            Row()
              .width('70%')
              .height(3)
              .backgroundColor('#CCCCCC')
              .borderRadius(1)
              .margin({ top: 6 })
          }, (item: number) => item.toString())
        }
        .alignItems(HorizontalAlign.Start)
        .padding({ left: 20 })
      }
      .width('100%')

      // 模板信息
      Column() {
        Row() {
          Text(this.template.name)
            .fontSize(15)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1A1A1A')

          Blank()

          if (this.isSelected) {
            Text('已选')
              .fontSize(11)
              .fontColor('#FFFFFF')
              .backgroundColor(this.template.palette.primary)
              .borderRadius(10)
              .padding({ left: 8, right: 8, top: 2, bottom: 2 })
          }
        }
        .width('100%')

        Text(this.template.description)
          .fontSize(12)
          .fontColor('#9CA3AF')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .margin({ top: 4 })
          .width('100%')
      }
      .width('100%')
      .padding({ left: 12, right: 12, top: 10, bottom: 12 })
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
    .borderRadius(12)
    .border({
      width: this.isSelected ? 2 : 0,
      color: this.template.palette.primary
    })
    .shadow({
      radius: this.isSelected ? 12 : 6,
      color: '#00000015',
      offsetX: 0,
      offsetY: this.isSelected ? 4 : 2
    })
    .onClick(() => {
      if (this.onSelect !== undefined) {
        this.onSelect();
      }
    })
  }

  getBgColor(): ResourceColor {
    if (this.template.id === 'classic-blue') {
      return '#EBF4FF';
    }
    if (this.template.id === 'modern-green') {
      return '#ECFDF5';
    }
    return '#F3F4F6';
  }
}
