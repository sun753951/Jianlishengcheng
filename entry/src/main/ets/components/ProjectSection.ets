/**
 * ProjectSection — 项目经历章节组件
 * 替代 EditableSectionCard + @BuilderParam 模式，使用 @Link 绑定数据以支持动态刷新
 */
import { ResumeData, Project } from '../model/ResumeData';
import { EditableStringList } from './EditableStringList';

@Component
export struct ProjectSection {
  @Link resumeData: ResumeData;
  @State isExpanded: boolean = false;

  onAutoSave: () => void = () => {};

  private copyProject(src: Project): Project {
    const item: Project = new Project();
    item.id = src.id;
    item.name = src.name;
    item.role = src.role;
    item.startDate = src.startDate;
    item.endDate = src.endDate;
    item.description = src.description;
    item.highlights = [...src.highlights];
    item.technologies = [...src.technologies];
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

        Text('项目经历')
          .fontSize(16)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        if (this.resumeData.projects.length > 0) {
          Text(this.resumeData.projects.length.toString())
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
            const item: Project = new Project();
            item.id = Date.now().toString();
            this.resumeData.projects = [...this.resumeData.projects, item];
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
          ForEach(this.resumeData.projects, (item: Project, index: number) => {
            Column() {
              // 项目名称 + 角色
              Row() {
                TextInput({ placeholder: '项目名称', text: item.name })
                  .layoutWeight(1)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .border({ width: 1, color: '#E5E7EB' })
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .fontSize(13)
                  .margin({ right: 8 })
                  .onChange((value: string) => {
                    const updated: Project = this.copyProject(item);
                    updated.name = value;
                    const newArr: Project[] = [...this.resumeData.projects];
                    newArr[index] = updated;
                    this.resumeData.projects = newArr;
                    this.onAutoSave();
                  })

                TextInput({ placeholder: '角色', text: item.role })
                  .layoutWeight(1)
                  .backgroundColor('#FFFFFF')
                  .borderRadius(8)
                  .border({ width: 1, color: '#E5E7EB' })
                  .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                  .fontSize(13)
                  .onChange((value: string) => {
                    const updated: Project = this.copyProject(item);
                    updated.role = value;
                    const newArr: Project[] = [...this.resumeData.projects];
                    newArr[index] = updated;
                    this.resumeData.projects = newArr;
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
                    const updated: Project = this.copyProject(item);
                    updated.startDate = value;
                    const newArr: Project[] = [...this.resumeData.projects];
                    newArr[index] = updated;
                    this.resumeData.projects = newArr;
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
                    const updated: Project = this.copyProject(item);
                    updated.endDate = value;
                    const newArr: Project[] = [...this.resumeData.projects];
                    newArr[index] = updated;
                    this.resumeData.projects = newArr;
                    this.onAutoSave();
                  })
              }
              .width('100%')
              .margin({ bottom: 8 })

              // 项目描述
              TextArea({ placeholder: '项目描述', text: item.description })
                .width('100%')
                .backgroundColor('#FFFFFF')
                .borderRadius(8)
                .border({ width: 1, color: '#E5E7EB' })
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .fontSize(13)
                .margin({ bottom: 8 })
                .onChange((value: string) => {
                  const updated: Project = this.copyProject(item);
                  updated.description = value;
                  const newArr: Project[] = [...this.resumeData.projects];
                  newArr[index] = updated;
                  this.resumeData.projects = newArr;
                  this.onAutoSave();
                })

              // 项目亮点
              EditableStringList({
                items: item.highlights,
                placeholder: '输入亮点',
                addButtonText: '+ 添加亮点',
                onChange: (newItems: string[]): void => {
                  const updated: Project = this.copyProject(item);
                  updated.highlights = newItems;
                  const newArr: Project[] = [...this.resumeData.projects];
                  newArr[index] = updated;
                  this.resumeData.projects = newArr;
                  this.onAutoSave();
                }
              })

              // 技术栈
              EditableStringList({
                items: item.technologies,
                placeholder: '输入技术栈',
                addButtonText: '+ 添加技术',
                onChange: (newItems: string[]): void => {
                  const updated: Project = this.copyProject(item);
                  updated.technologies = newItems;
                  const newArr: Project[] = [...this.resumeData.projects];
                  newArr[index] = updated;
                  this.resumeData.projects = newArr;
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
                  this.resumeData.projects = this.resumeData.projects.filter(
                    (_: Project, i: number): boolean => i !== index
                  );
                  this.onAutoSave();
                })
            }
            .padding(12)
            .borderRadius(8)
            .backgroundColor('#F9FAFB')
            .margin({ bottom: 12 })
          }, (item: Project, index: number) => item.id + index.toString())
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
