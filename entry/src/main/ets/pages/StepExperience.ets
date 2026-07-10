import router from '@ohos.router';
import { createDemoResumeForm, ResumeDataHolder } from '../model/ResumeModels';
import { PRIMARY, PRIMARY_LIGHT, BG_PAGE, BORDER_DEFAULT } from '../style/Colors';

@Entry
@Component
struct StepExperience {
  @State education: string = ResumeDataHolder.getInstance().formData.education;
  @State targetPosition: string = ResumeDataHolder.getInstance().formData.targetPosition;
  @State skills: string = ResumeDataHolder.getInstance().formData.skills;
  @State workExperience: string = ResumeDataHolder.getInstance().formData.workExperience;
  @State projectExperience: string = ResumeDataHolder.getInstance().formData.projectExperience;
  @State selfEvaluation: string = ResumeDataHolder.getInstance().formData.selfEvaluation;

  @Builder
  private stepIndicator(current: number) {
    Row({ space: 0 }) {
      ForEach([1, 2, 3, 4], (step: number, index: number) => {
        Row({ space: 0 }) {
          Column({ space: 2 }) {
            Column() {
              if (step < current) {
                Text('\u2713')
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#FFFFFF');
              } else {
                Text(`${step}`)
                  .fontSize(12)
                  .fontWeight(FontWeight.Bold)
                  .fontColor(step === current ? '#FFFFFF' : '#9CA3AF');
              }
            }
            .width(24)
            .height(24)
            .borderRadius(12)
            .justifyContent(FlexAlign.Center)
            .backgroundColor(step <= current ? PRIMARY : '#E5E7EB');
            Text(step === 1 ? '基本信息' : step === 2 ? '经历' : step === 3 ? '模板' : '预览')
              .fontSize(9)
              .fontColor(step <= current ? PRIMARY : '#9CA3AF');
          }
          .alignItems(HorizontalAlign.Center);

          if (index < 3) {
            Divider()
              .width(24)
              .height(1)
              .color(step < current ? PRIMARY : '#E5E7EB')
              .margin({ top: -8 });
          }
        }
      });
    }
    .justifyContent(FlexAlign.Center)
    .width('100%')
    .padding({ top: 8, bottom: 8 });
  }

  @Builder
  private sectionTitle(title: string, caption: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#111827');
      Text(caption)
        .fontSize(13)
        .fontColor('#6B7280');
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .margin({ bottom: 16 });
  }

  @Builder
  private multiLineInput(label: string, value: string, placeholder: string, tall: boolean, onChange: (v: string) => void) {
    Column({ space: 6 }) {
      Text(label)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#374151')
        .width('100%');
      TextArea({ text: value, placeholder: placeholder })
        .fontSize(15)
        .width('100%')
        .height(tall ? 120 : 80)
        .borderRadius(12)
        .backgroundColor(PRIMARY_LIGHT)
        .border({ width: 1, color: BORDER_DEFAULT })
        .padding(12)
        .onChange(onChange);
    }
    .width('100%');
  }

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          this.stepIndicator(2);
          this.sectionTitle('经历填写', '第 2 步 / 共 4 步 — 填写您的教育和工作经历');

          Column({ space: 14 }) {
            Row({ space: 12 }) {
              Column({ space: 6 }) {
                Text('求职岗位')
                  .fontSize(14)
                  .fontWeight(FontWeight.Medium)
                  .fontColor('#374151')
                  .width('100%');
                TextInput({ text: this.targetPosition, placeholder: '如：HarmonyOS开发者' })
                  .fontSize(16)
                  .width('100%')
                  .height(48)
                  .borderRadius(12)
                  .backgroundColor(PRIMARY_LIGHT)
                  .border({ width: 1, color: BORDER_DEFAULT })
                  .onChange((value: string) => { this.targetPosition = value; });
              }
              .layoutWeight(1);
            };

            this.multiLineInput('教育经历', this.education, '学校、专业、学历、GPA等', false, (v: string) => { this.education = v; });
            this.multiLineInput('技能', this.skills, '如：ArkTS、ArkUI、HarmonyOS开发', false, (v: string) => { this.skills = v; });
            this.multiLineInput('工作经历', this.workExperience, '公司名称、岗位、职责与成果', true, (v: string) => { this.workExperience = v; });
            this.multiLineInput('项目经历', this.projectExperience, '项目名称、个人职责、真实结果', true, (v: string) => { this.projectExperience = v; });
            this.multiLineInput('自我评价', this.selfEvaluation, '学习能力、协作能力、职业态度', false, (v: string) => { this.selfEvaluation = v; });

            // Demo fill button
            Button('一键填充演示数据')
              .fontSize(14)
              .fontColor(PRIMARY)
              .width('100%')
              .height(40)
              .borderRadius(10)
              .backgroundColor(PRIMARY_LIGHT)
              .onClick(() => {
                const demo = createDemoResumeForm();
                this.education = demo.education;
                this.targetPosition = demo.targetPosition;
                this.skills = demo.skills;
                this.workExperience = demo.workExperience;
                this.projectExperience = demo.projectExperience;
                this.selfEvaluation = demo.selfEvaluation;
              });
          }
          .width('100%')
          .padding(16)
          .borderRadius(16)
          .backgroundColor('#FFFFFF')
          .border({ width: 1, color: BORDER_DEFAULT })
          .shadow({ radius: 12, color: 'rgba(0,0,0,0.07)', offsetY: 4 });
        }
      }
      .layoutWeight(1);

      Row({ space: 12 }) {
        Button('\u2190 上一步')
          .fontSize(15)
          .fontColor('#6B7280')
          .layoutWeight(1)
          .height(48)
          .borderRadius(12)
          .backgroundColor('#F3F4F6')
          .onClick(() => {
            const holder = ResumeDataHolder.getInstance();
            holder.formData.education = this.education;
            holder.formData.targetPosition = this.targetPosition;
            holder.formData.skills = this.skills;
            holder.formData.workExperience = this.workExperience;
            holder.formData.projectExperience = this.projectExperience;
            holder.formData.selfEvaluation = this.selfEvaluation;
            router.back();
          });

        Button('下一步 \u2192')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .height(48)
          .borderRadius(12)
          .backgroundColor(PRIMARY)
          .onClick(() => {
            const holder = ResumeDataHolder.getInstance();
            holder.formData.education = this.education;
            holder.formData.targetPosition = this.targetPosition;
            holder.formData.skills = this.skills;
            holder.formData.workExperience = this.workExperience;
            holder.formData.projectExperience = this.projectExperience;
            holder.formData.selfEvaluation = this.selfEvaluation;
            router.pushUrl({ url: 'pages/StepTemplate' });
          });
      }
      .width('100%')
      .padding(16)
      .backgroundColor('#FFFFFF');
    }
    .width('100%')
    .height('100%')
    .backgroundColor(BG_PAGE);
  }
}
