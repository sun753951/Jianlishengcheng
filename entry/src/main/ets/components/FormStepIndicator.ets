/**
 * 表单步骤指示器 — 显示多步表单当前进度
 */

export class FormStep {
  label: string = '';
  isCompleted: boolean = false;
  isActive: boolean = false;

  constructor(label: string, isCompleted: boolean, isActive: boolean) {
    this.label = label;
    this.isCompleted = isCompleted;
    this.isActive = isActive;
  }
}

@Component
export struct FormStepIndicator {
  @Prop steps: FormStep[] = [];
  @Prop currentStep: number = 0;

  build() {
    Row() {
      ForEach(this.steps, (step: FormStep, index: number) => {
        Row() {
          // 步骤圆点
          Column() {
            if (step.isCompleted) {
              // 已完成：对勾图标
              Text('✓')
                .fontSize(12)
                .fontColor('#FFFFFF')
            } else {
              Text((index + 1).toString())
                .fontSize(12)
                .fontColor(step.isActive ? '#FFFFFF' : '#9CA3AF')
            }
          }
          .width(24)
          .height(24)
          .borderRadius(12)
          .backgroundColor(this.getDotColor(step))
          .justifyContent(FlexAlign.Center)

          // 步骤标签
          Text(step.label)
            .fontSize(11)
            .fontColor(step.isActive ? '#1A56DB' : '#9CA3AF')
            .fontWeight(step.isActive ? FontWeight.Bold : FontWeight.Normal)
            .margin({ top: 4 })
            .textAlign(TextAlign.Center)
        }
        .alignItems(VerticalAlign.Center)

        // 连接线
        if (index < this.steps.length - 1) {
          Row()
            .width('100%')
            .height(2)
            .backgroundColor(step.isCompleted ? '#1A56DB' : '#E5E7EB')
            .margin({ left: 4, right: 4, bottom: 20 })
            .layoutWeight(1)
        }
      }, (step: FormStep, index: number) => step.label)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ left: 16, right: 16 })
  }

  getDotColor(step: FormStep): ResourceColor {
    if (step.isCompleted) {
      return '#059669';
    }
    if (step.isActive) {
      return '#1A56DB';
    }
    return '#E5E7EB';
  }
}
