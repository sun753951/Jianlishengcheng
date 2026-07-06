/**
 * SkillItem — 单条技能行：技能名 TextInput + 熟练度 Slider + 数值标签 + 删除按钮
 */
import { Skill } from '../model/ResumeData';

@Component
export struct SkillItem {
  @Prop skill: Skill = new Skill();

  onChange: (skill: Skill) => void = () => {};
  onDelete: () => void = () => {};

  build() {
    Row() {
      TextInput({ placeholder: '技能名称', text: this.skill.name })
        .width('40%')
        .backgroundColor('#F9FAFB')
        .borderRadius(8)
        .border({ width: 1, color: '#E5E7EB' })
        .padding({ left: 10, right: 10, top: 6, bottom: 6 })
        .fontSize(13)
        .onChange((value: string) => {
          const updated: Skill = new Skill();
          updated.id = this.skill.id;
          updated.name = value;
          updated.level = this.skill.level;
          updated.category = this.skill.category;
          this.onChange(updated);
        })

      Text(this.skill.level.toString() + '%')
        .fontSize(12)
        .fontColor('#6B7280')
        .width(42)
        .textAlign(TextAlign.Center)

      Slider({
        value: this.skill.level,
        min: 0,
        max: 100,
        step: 1,
        style: SliderStyle.OutSet,
        direction: Axis.Horizontal
      })
        .width('35%')
        .blockColor('#1A56DB')
        .trackThickness(6)
        .onChange((value: number) => {
          const updated: Skill = new Skill();
          updated.id = this.skill.id;
          updated.name = this.skill.name;
          updated.level = value;
          updated.category = this.skill.category;
          this.onChange(updated);
        })

      Text('✕')
        .fontSize(16)
        .fontColor('#EF4444')
        .width(28)
        .textAlign(TextAlign.Center)
        .onClick(() => {
          this.onDelete();
        })
    }
    .width('100%')
    .margin({ bottom: 10 })
    .alignItems(VerticalAlign.Center)
  }
}
