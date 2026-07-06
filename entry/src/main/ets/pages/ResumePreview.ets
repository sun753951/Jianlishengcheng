/**
 * ResumePreview — 简历预览页面，支持三种模板渲染和PDF导出
 */
import router from '@ohos.router';
import {
  ResumeData, Education, WorkExperience,
  Project, Skill, Language, Certificate
} from '../model/ResumeData';
import { PdfGenerator } from '../utils/PdfGenerator';
import { TemplateConfig, TemplatePreset, TemplateType } from '../model/TemplateConfig';
import promptAction from '@ohos.promptAction';

@Entry
@Component
struct ResumePreview {
  @State resume: ResumeData = new ResumeData();
  @State currentTemplateType: string = 'classic';

  onPageShow(): void {
    const data: ResumeData | undefined = AppStorage.get<ResumeData>('currentResume');
    if (data !== undefined) {
      this.resume = data;
      this.currentTemplateType = data.templateType;
    }
  }

  build() {
    Column() {
      // 顶部操作栏
      Row() {
        Image($r('app.media.startIcon'))
          .width(24)
          .height(24)
          .onClick(() => {
            router.back();
          })

        Text('简历预览')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')
          .margin({ left: 12 })

        Blank()

        // 切换模板按钮
        Button('切换模板')
          .fontSize(12)
          .fontColor('#1A56DB')
          .backgroundColor('#EBF4FF')
          .borderRadius(6)
          .height(32)
          .onClick(() => {
            this.switchTemplate();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 8 })

      // 简历内容 — 可滚动
      Scroll() {
        Column() {
          if (this.currentTemplateType === TemplateType.CLASSIC) {
            this.buildClassicTemplate()
          } else if (this.currentTemplateType === TemplateType.MODERN) {
            this.buildModernTemplate()
          } else {
            this.buildMinimalTemplate()
          }
        }
        .width('100%')
        .padding({ bottom: 100 })
      }
      .width('100%')
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .backgroundColor('#FFFFFF')

      // 底部按钮
      Row() {
        Button('编辑简历')
          .fontSize(14)
          .fontColor('#6B7280')
          .backgroundColor('#F3F4F6')
          .borderRadius(8)
          .height(44)
          .layoutWeight(1)
          .margin({ right: 12 })
          .stateStyles({
            pressed: { .backgroundColor('#E5E7EB') }
          })
          .onClick(() => {
            router.pushUrl({ url: 'pages/ResumeEditor' });
          })

        Button('导出PDF')
          .fontSize(14)
          .fontColor('#FFFFFF')
          .backgroundColor('#1A56DB')
          .borderRadius(8)
          .height(44)
          .layoutWeight(1)
          .stateStyles({
            pressed: { .backgroundColor('#1649C7') }
          })
          .onClick(() => {
            this.exportPdf();
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12, bottom: 24 })
      .backgroundColor('#FFFFFF')
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F5F5F5')
  }

  // ==================== 经典模板 ====================
  @Builder
  buildClassicTemplate() {
    Column() {
      // 页眉
      Column() {
        Text(this.resume.personalInfo.name || '您的姓名')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1A1A1A')

        Text(this.resume.personalInfo.title || '您的职位')
          .fontSize(15)
          .fontColor('#6B7280')
          .margin({ top: 4 })

        // 联系方式行
        Row() {
          if (this.resume.personalInfo.phone.length > 0) {
            Text('📱 ' + this.resume.personalInfo.phone)
              .fontSize(12)
              .fontColor('#9CA3AF')
              .margin({ right: 16 })
          }
          if (this.resume.personalInfo.email.length > 0) {
            Text('📧 ' + this.resume.personalInfo.email)
              .fontSize(12)
              .fontColor('#9CA3AF')
          }
        }
        .margin({ top: 8 })
      }
      .width('100%')
      .padding({ top: 24, bottom: 20, left: 24, right: 24 })
      .backgroundColor('#F8FAFC')

      // 分隔线
      Divider().height(3).color('#1A56DB')

      // 个人总结
      if (this.resume.personalInfo.summary.length > 0) {
        Column() {
          this.buildSectionHeader('个人简介')
          Text(this.resume.personalInfo.summary)
            .fontSize(14)
            .fontColor('#4B5563')
            .lineHeight(22)
            .margin({ top: 8 })
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 16, bottom: 8 })
        .alignItems(HorizontalAlign.Start)
      }

      // 工作经历
      if (this.resume.workExperience.length > 0) {
        Column() {
          this.buildSectionHeader('工作经历')
          ForEach(this.resume.workExperience, (work: WorkExperience, idx: number) => {
            Column() {
              Row() {
                Text(work.position)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A')
                Blank()
                Text(work.startDate + ' - ' + (work.current ? '至今' : work.endDate))
                  .fontSize(12)
                  .fontColor('#9CA3AF')
              }
              .width('100%')

              Text(work.company)
                .fontSize(13)
                .fontColor('#6B7280')
                .margin({ top: 2 })

              Text(work.description)
                .fontSize(13)
                .fontColor('#4B5563')
                .lineHeight(20)
                .margin({ top: 6 })
                .maxLines(3)

              if (work.achievements.length > 0) {
                ForEach(work.achievements, (achi: string, aIdx: number) => {
                  Row() {
                    Text('• ' + achi)
                      .fontSize(12)
                      .fontColor('#6B7280')
                      .lineHeight(20)
                  }
                  .width('100%')
                  .margin({ top: 3 })
                }, (achi: string, aIdx: number) => aIdx.toString())
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ top: 12 })
            .padding({ bottom: 8 })
            .border({
              width: { bottom: idx < this.resume.workExperience.length - 1 ? 1 : 0 },
              color: '#F3F4F6'
            })
          }, (work: WorkExperience, idx: number) => work.id + idx.toString())
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 16, bottom: 4 })
        .alignItems(HorizontalAlign.Start)
      }

      // 教育经历
      if (this.resume.education.length > 0) {
        Column() {
          this.buildSectionHeader('教育经历')
          ForEach(this.resume.education, (edu: Education, idx: number) => {
            Row() {
              Column() {
                Text(edu.school)
                  .fontSize(14)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A')
                Text(edu.degree + ' · ' + edu.major)
                  .fontSize(13)
                  .fontColor('#6B7280')
                  .margin({ top: 2 })
              }
              .alignItems(HorizontalAlign.Start)
              Blank()
              Text(edu.startDate + ' - ' + edu.endDate)
                .fontSize(12)
                .fontColor('#9CA3AF')
            }
            .width('100%')
            .margin({ top: idx > 0 ? 10 : 6 })
          }, (edu: Education, idx: number) => edu.id + idx.toString())
        }
        .width('100%')
        .padding({ left: 24, right: 24, top: 16, bottom: 4 })
        .alignItems(HorizontalAlign.Start)
      }

      // 底部留白
      Blank().height(24)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  // ==================== 现代模板 ====================
  @Builder
  buildModernTemplate() {
    Row() {
      // 左侧边栏
      Column() {
        // 头像占位
        Circle()
          .width(64)
          .height(64)
          .fill('#E5E7EB')
          .margin({ top: 24 })

        Text(this.resume.personalInfo.name || '姓名')
          .fontSize(18)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .margin({ top: 12 })

        Text(this.resume.personalInfo.title || '职位')
          .fontSize(13)
          .fontColor('#D1FAE5')
          .margin({ top: 4 })

        Divider()
          .color('#FFFFFF40')
          .margin({ top: 16, bottom: 12 })
          .width('80%')

        // 联系信息
        if (this.resume.personalInfo.phone.length > 0) {
          Text('📱 ' + this.resume.personalInfo.phone)
            .fontSize(11)
            .fontColor('#D1FAE5')
            .margin({ top: 8 })
            .maxLines(1)
        }
        if (this.resume.personalInfo.email.length > 0) {
          Text('📧 ' + this.resume.personalInfo.email)
            .fontSize(11)
            .fontColor('#D1FAE5')
            .margin({ top: 6 })
            .maxLines(1)
        }

        // 技能
        if (this.resume.skills.length > 0) {
          Text('技能')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .margin({ top: 20, bottom: 8 })
          ForEach(this.resume.skills.slice(0, 6), (skill: Skill, idx: number) => {
            Text(skill.name)
              .fontSize(11)
              .fontColor('#D1FAE5')
              .margin({ top: 4 })
          }, (skill: Skill, idx: number) => skill.id + idx.toString())
        }
      }
      .width(140)
      .height('100%')
      .backgroundColor('#059669')
      .padding({ left: 12, right: 12 })
      .alignItems(HorizontalAlign.Center)

      // 右侧主内容
      Column() {
        // 个人总结
        if (this.resume.personalInfo.summary.length > 0) {
          Column() {
            this.buildSectionHeader('关于我')
            Text(this.resume.personalInfo.summary)
              .fontSize(13)
              .fontColor('#4B5563')
              .lineHeight(20)
              .margin({ top: 6 })
              .maxLines(4)
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 20, bottom: 4 })
        }

        // 工作经历
        if (this.resume.workExperience.length > 0) {
          Column() {
            this.buildSectionHeader('工作经历')
            ForEach(this.resume.workExperience, (work: WorkExperience, idx: number) => {
              Column() {
                Text(work.position + ' @ ' + work.company)
                  .fontSize(13)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#1A1A1A')
                Text(work.startDate + ' - ' + (work.current ? '至今' : work.endDate))
                  .fontSize(11)
                  .fontColor('#9CA3AF')
                  .margin({ top: 2 })
                Text(work.description)
                  .fontSize(12)
                  .fontColor('#6B7280')
                  .lineHeight(18)
                  .margin({ top: 4 })
                  .maxLines(2)
              }
              .width('100%')
              .alignItems(HorizontalAlign.Start)
              .margin({ top: 8, bottom: 4 })
            }, (work: WorkExperience, idx: number) => work.id + idx.toString())
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: 16, right: 16, top: 12, bottom: 4 })
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }
    .width('100%')
    .backgroundColor('#FFFFFF')
  }

  // ==================== 极简模板 ====================
  @Builder
  buildMinimalTemplate() {
    Column() {
      // 简洁标题
      Text(this.resume.personalInfo.name || '姓名')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827')

      Text(this.resume.personalInfo.title || '职位')
        .fontSize(14)
        .fontColor('#6B7280')
        .margin({ top: 4 })

      Row() {
        if (this.resume.personalInfo.phone.length > 0) {
          Text(this.resume.personalInfo.phone)
            .fontSize(11)
            .fontColor('#9CA3AF')
            .margin({ right: 16 })
        }
        if (this.resume.personalInfo.email.length > 0) {
          Text(this.resume.personalInfo.email)
            .fontSize(11)
            .fontColor('#9CA3AF')
        }
      }
      .margin({ top: 8 })

      // 分隔
      Row()
        .width('100%')
        .height(1)
        .backgroundColor('#E5E7EB')
        .margin({ top: 16, bottom: 12 })

      // 工作经历
      if (this.resume.workExperience.length > 0) {
        Column() {
          Text('工作经验')
            .fontSize(11)
            .fontColor('#9CA3AF')
            .fontWeight(FontWeight.Bold)
            .letterSpacing(2)
            .textCase(TextCase.UpperCase)

          ForEach(this.resume.workExperience, (work: WorkExperience, idx: number) => {
            Column() {
              Row() {
                Text(work.position)
                  .fontSize(15)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#111827')
                Blank()
                Text(work.startDate + ' - ' + (work.current ? '至今' : work.endDate))
                  .fontSize(11)
                  .fontColor('#9CA3AF')
              }
              .width('100%')

              Text(work.company)
                .fontSize(13)
                .fontColor('#6B7280')
                .margin({ top: 2 })

              Text(work.description)
                .fontSize(13)
                .fontColor('#4B5563')
                .lineHeight(20)
                .margin({ top: 6 })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .margin({ top: 10 })
          }, (work: WorkExperience, idx: number) => work.id + idx.toString())
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      // 教育
      if (this.resume.education.length > 0) {
        Row()
          .width('100%')
          .height(1)
          .backgroundColor('#F3F4F6')
          .margin({ top: 16, bottom: 12 })

        Column() {
          Text('教育背景')
            .fontSize(11)
            .fontColor('#9CA3AF')
            .fontWeight(FontWeight.Bold)
            .letterSpacing(2)

          ForEach(this.resume.education, (edu: Education, idx: number) => {
            Row() {
              Text(edu.school)
                .fontSize(13)
                .fontWeight(FontWeight.Bold)
                .fontColor('#111827')
              Text(' · ' + edu.degree + ' · ' + edu.major)
                .fontSize(13)
                .fontColor('#6B7280')
                .margin({ left: 6 })
            }
            .margin({ top: 6 })
          }, (edu: Education, idx: number) => edu.id + idx.toString())
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }
    }
    .width('100%')
    .padding({ left: 24, right: 24, top: 28, bottom: 24 })
    .alignItems(HorizontalAlign.Start)
    .backgroundColor('#FFFFFF')
  }

  // ==================== 通用构建器 ====================
  @Builder
  buildSectionHeader(title: string) {
    Text(title)
      .fontSize(16)
      .fontWeight(FontWeight.Bold)
      .fontColor('#1A1A1A')
      .margin({ bottom: 4 })
  }

  // ==================== 模板切换 ====================
  switchTemplate(): void {
    const types: string[] = [TemplateType.CLASSIC, TemplateType.MODERN, TemplateType.MINIMAL];
    const currentIndex: number = types.indexOf(this.currentTemplateType);
    const nextIndex: number = (currentIndex + 1) % types.length;
    this.currentTemplateType = types[nextIndex];
    const names: string[] = ['经典蓝', '现代绿', '极简黑'];
    promptAction.showToast({ message: '已切换为：' + names[nextIndex], duration: 1500 });
  }

  // ==================== PDF导出 ====================
  exportPdf(): void {
    const config: TemplateConfig = TemplatePreset.getPresets()[0];
    PdfGenerator.exportToPdf(this.resume, config).then((result) => {
      if (result.success) {
        promptAction.showToast({ message: 'PDF导出成功', duration: 2000 });
      } else {
        promptAction.showToast({ message: result.errorMessage, duration: 2000 });
      }
    });
  }
}
