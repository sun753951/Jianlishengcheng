import router from '@ohos.router';
import { createDemoResumeForm, ResumeDataHolder } from '../model/ResumeModels';

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
    Row({ space: 8 }) {
      ForEach([1, 2, 3, 4], (step: number) => {
        Circle({ width: 10, height: 10 })
          .fill(step <= current ? '#2563EB' : '#D1D5DB');
      });
    }
    .justifyContent(FlexAlign.Center)
    .margin({ bottom: 24 });
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
        .backgroundColor('#F9FAFB')
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
                  .backgroundColor('#F9FAFB')
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
              .fontColor('#7C3AED')
              .width('100%')
              .height(40)
              .borderRadius(10)
              .backgroundColor('#F5F3FF')
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
          .border({ width: 1, color: '#DDE7FF' });
        }
      }
      .layoutWeight(1);

      Row({ space: 12 }) {
        Button('← 上一步')
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

        Button('下一步 →')
          .fontSize(15)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
          .layoutWeight(1)
          .height(48)
          .borderRadius(12)
          .backgroundColor('#2563EB')
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
    .backgroundColor('#F8FAFC');
  }
}