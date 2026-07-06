/**
 * WorkExperienceSection — 工作经历章节组件
 * 替代 EditableSectionCard + @BuilderParam 模式，使用 @Link 绑定数据以支持动态刷新
 */
import { ResumeData, WorkExperience } from '../model/ResumeData';
import { EditableStringList } from './EditableStringList';

@Component
export struct WorkExperienceSection {
  @Link resumeData: ResumeData;
  @State isExpanded: boolean = true;

  onAutoSave: () => void = () => {};

  private copyWork(src: WorkExperience): WorkExperience {
    const item: WorkExperience = new WorkExperience();
    item.id = src.id;
    item.company = src.company;
    item.position = src.position;
    item.startDate = src.startDate;
    item.endDate = src.endDate;
    item.current = src.current;
    item.description = src.description;
    item.achievements = [...src.achievements];
    return item;
  }

  build() {
    Column() {
      // ===== 头部：可折叠 + 添加按钮 =====
      Row() {
        Text(this.isExpanded ? '▼' : '▶')
          .fontSize(12)
          .fontColor('#6B7280')
          .width(20)

        Text('工作经历')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        if (this.resumeData.workExperience.length > 0) {
          Text(this.resumeData.workExperience.length.toString())
            .fontSize(11)
            .fontColor('#FFFFFF')
            .backgroundColor('#1A56DB')
            .borderRadius(10)
            .padding({ left: 6, right: 6, top: 1, bottom: 1 })
            .margin({ left: 8 })
        }

        Blank()

        Text('+ 添加')
          .fontSize(12)
          .fontColor('#1A56DB')
          .backgroundColor('#EBF4FF')
          .borderRadius(6)
          .padding({ left: 10, right: 10, top: 4, bottom: 4 })
          .onClick(() => {
            const item: WorkExperience = new WorkExperience();
            item.id = Date.now().toString();
            this.resumeData.workExperience = [...this.resumeData.workExperience, item];
            this.onAutoSave();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 14, bottom: 14 })
      .onClick(() => {
        this.isExpanded = !this.isExpanded;
      })

      // ===== 内容区 =====
      if (this.isExpanded) {
        Divider()
          .color('#F3F4F6')
          .width('100%')

        Column() {
          ForEach(this.resumeData.workExperience, (item: WorkExperience, index: number) => {
            Column() {
              // 公司 + 职位
              Row() {
                TextInput({ placeholder: '公司名称', text: item.company })
                  .layoutWeight(1)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .border({ width: 1, color: '#E5E7EB' })
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .fontSize(13)
                  .margin({ right: 8 })
                  .onChange((value: string) => {
                    const updated: WorkExperience = this.copyWork(item);
                    updated.company = value;
                    const newArr: WorkExperience[] = [...this.resumeData.workExperience];
                    newArr[index] = updated;
                    this.resumeData.workExperience = newArr;
                    this.onAutoSave();
                  })

                TextInput({ placeholder: '职位', text: item.position })
                  .layoutWeight(1)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .border({ width: 1, color: '#E5E7EB' })
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .fontSize(13)
                  .onChange((value: string) => {
                    const updated: WorkExperience = this.copyWork(item);
                    updated.position = value;
                    const newArr: WorkExperience[] = [...this.resumeData.workExperience];
                    newArr[index] = updated;
                    this.resumeData.workExperience = newArr;
                    this.onAutoSave();
                  })
              }
              .width('100%')
              .margin({ bottom: 8 })

              // 日期
              Row() {
                TextInput({ placeholder: '开始日期', text: item.startDate })
                  .layoutWeight(1)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .border({ width: 1, color: '#E5E7EB' })
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .fontSize(13)
                  .margin({ right: 8 })
                  .onChange((value: string) => {
                    const updated: WorkExperience = this.copyWork(item);
                    updated.startDate = value;
                    const newArr: WorkExperience[] = [...this.resumeData.workExperience];
                    newArr[index] = updated;
                    this.resumeData.workExperience = newArr;
                    this.onAutoSave();
                  })

                TextInput({ placeholder: '结束日期', text: item.endDate })
                  .layoutWeight(1)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .border({ width: 1, color: '#E5E7EB' })
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .fontSize(13)
                  .onChange((value: string) => {
                    const updated: WorkExperience = this.copyWork(item);
                    updated.endDate = value;
                    const newArr: WorkExperience[] = [...this.resumeData.workExperience];
                    newArr[index] = updated;
                    this.resumeData.workExperience = newArr;
                    this.onAutoSave();
                  })
              }
              .width('100%')
              .margin({ bottom: 8 })

              // 工作描述
              TextArea({ placeholder: '工作描述', text: item.description })
                .width('100%')
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .border({ width: 1, color: '#E5E7EB' })
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .fontSize(13)
                .margin({ bottom: 8 })
                .onChange((value: string) => {
                  const updated: WorkExperience = this.copyWork(item);
                  updated.description = value;
                  const newArr: WorkExperience[] = [...this.resumeData.workExperience];
                  newArr[index] = updated;
                  this.resumeData.workExperience = newArr;
                  this.onAutoSave();
                })

              // 成就列表
              EditableStringList({
                items: item.achievements,
                placeholder: '输入成就',
                addButtonText: '+ 添加成就',
                onChange: (newItems: string[]): void => {
                  const updated: WorkExperience = this.copyWork(item);
                  updated.achievements = newItems;
                  const newArr: WorkExperience[] = [...this.resumeData.workExperience];
                  newArr[index] = updated;
                  this.resumeData.workExperience = newArr;
                  this.onAutoSave();
                }
              })

              // 删除按钮
              Button('删除本条')
                .fontSize(12)
                .fontColor('#EF4444')
                .backgroundColor('#FEF2F2')
                .borderRadius(6)
                .height(30)
                .margin({ top: 8 })
                .onClick(() => {
                  this.resumeData.workExperience = this.resumeData.workExperience.filter(
                    (_: WorkExperience, i: number): boolean => i !== index
                  );
                  this.onAutoSave();
                })
            }
            .padding(12)
            .borderRadius(8)
            .backgroundColor('#F9FAFB')
            .margin({ bottom: 12 })
          }, (item: WorkExperience, index: number) => item.id + index.toString())
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
