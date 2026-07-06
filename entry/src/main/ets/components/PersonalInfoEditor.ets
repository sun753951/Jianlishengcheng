/**
 * 个人信息编辑器 — 11 个字段的编辑表单
 */
import { PersonalInfo } from '../model/ResumeData';

@Component
export struct PersonalInfoEditor {
  @ObjectLink personalInfo: PersonalInfo;

  build() {
    Column() {
      this.buildTextField('姓名', this.personalInfo.name, '请输入您的姓名',
        (value: string) => { this.personalInfo.name = value; })

      this.buildTextField('性别', this.personalInfo.gender, '男 / 女',
        (value: string) => { this.personalInfo.gender = value; })

      this.buildTextField('出生日期', this.personalInfo.birthDate, 'YYYY-MM',
        (value: string) => { this.personalInfo.birthDate = value; })

      this.buildTextField('手机号码', this.personalInfo.phone, '请输入手机号码',
        (value: string) => { this.personalInfo.phone = value; })

      this.buildTextField('邮箱', this.personalInfo.email, '请输入邮箱地址',
        (value: string) => { this.personalInfo.email = value; })

      this.buildTextField('地址', this.personalInfo.address, '所在城市',
        (value: string) => { this.personalInfo.address = value; })

      this.buildTextField('意向职位', this.personalInfo.title, '如：高级软件工程师',
        (value: string) => { this.personalInfo.title = value; })

      this.buildTextAreaField('个人简介', this.personalInfo.summary, '简要介绍您的职业背景和核心能力',
        (value: string) => { this.personalInfo.summary = value; })

      this.buildTextField('个人网站', this.personalInfo.website, 'https://',
        (value: string) => { this.personalInfo.website = value; })

      this.buildTextField('LinkedIn', this.personalInfo.linkedIn, 'linkedin.com/in/...',
        (value: string) => { this.personalInfo.linkedIn = value; })

      this.buildTextField('GitHub', this.personalInfo.github, 'github.com/...',
        (value: string) => { this.personalInfo.github = value; })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  buildTextField(label: string, value: string, placeholder: string,
    onChange: (value: string) => void) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor('#6B7280')
        .margin({ bottom: 4 })

      TextInput({ text: value, placeholder: placeholder })
        .fontSize(14)
        .fontColor('#1A1A1A')
        .backgroundColor('#F9FAFB')
        .borderRadius(8)
        .padding(12)
        .onChange(onChange)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
  }

  @Builder
  buildTextAreaField(label: string, value: string, placeholder: string,
    onChange: (value: string) => void) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor('#6B7280')
        .margin({ bottom: 4 })

      TextArea({ text: value, placeholder: placeholder })
        .fontSize(14)
        .fontColor('#1A1A1A')
        .backgroundColor('#F9FAFB')
        .borderRadius(8)
        .padding(12)
        .height(100)
        .onChange(onChange)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .margin({ bottom: 12 })
  }
}
