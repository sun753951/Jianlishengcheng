import router from '@ohos.router';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { ResumeDataHolder } from '../model/ResumeModels';

@Entry
@Component
struct StepBasicInfo {
  @State name: string = ResumeDataHolder.getInstance().formData.name;
  @State photoUri: string = ResumeDataHolder.getInstance().formData.photoUri;
  @State phone: string = ResumeDataHolder.getInstance().formData.phone;
  @State email: string = ResumeDataHolder.getInstance().formData.email;

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

  build() {
    Column() {
      Scroll() {
        Column({ space: 16 }) {
          this.stepIndicator(1);
          this.sectionTitle('基本信息', '第 1 步 / 共 4 步 — 填写您的身份信息');

          // Name
          Column({ space: 6 }) {
            Text('姓名')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#374151')
              .width('100%');
            TextInput({ text: this.name, placeholder: '请输入您的姓名' })
              .fontSize(16)
              .width('100%')
              .height(48)
              .borderRadius(12)
              .backgroundColor('#F9FAFB')
              .onChange((value: string) => { this.name = value; });
          };

          // Photo
          Column({ space: 6 }) {
            Text('头像')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#374151')
              .width('100%');
            Button(this.photoUri ? '已选择头像' : '选择头像')
              .fontSize(14)
              .fontColor(this.photoUri ? '#059669' : '#2563EB')
              .width('100%')
              .height(48)
              .borderRadius(12)
              .backgroundColor(this.photoUri ? '#ECFDF5' : '#EFF6FF')
              .onClick(async () => {
                try {
                  const photoSelectOptions = new photoAccessHelper.PhotoSelectOptions();
                  photoSelectOptions.MIMEType = photoAccessHelper.PhotoViewMIMETypes.IMAGE_TYPE;
                  const photoPicker = new photoAccessHelper.PhotoViewPicker();
                  const result: photoAccessHelper.PhotoSelectResult = await photoPicker.select(photoSelectOptions);
                  if (result && result.photoUris && result.photoUris.length > 0) {
                    this.photoUri = result.photoUris[0];
                  }
                } catch (_e) {
                  // user cancelled
                }
              });
            Text('提示: 点击模拟器工具栏📷截图，截图存入图库后即可选择')
              .fontSize(11).fontColor('#9CA3AF').width('100%').textAlign(TextAlign.Center);
          };

          // Phone
          Column({ space: 6 }) {
            Text('电话')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#374151')
              .width('100%');
            TextInput({ text: this.phone, placeholder: '请输入电话号码' })
              .fontSize(16)
              .type(InputType.PhoneNumber)
              .width('100%')
              .height(48)
              .borderRadius(12)
              .backgroundColor('#F9FAFB')
              .onChange((value: string) => { this.phone = value; });
          };

          // Email
          Column({ space: 6 }) {
            Text('邮箱')
              .fontSize(14)
              .fontWeight(FontWeight.Medium)
              .fontColor('#374151')
              .width('100%');
            TextInput({ text: this.email, placeholder: '请输入邮箱地址' })
              .fontSize(16)
              .type(InputType.Email)
              .width('100%')
              .height(48)
              .borderRadius(12)
              .backgroundColor('#F9FAFB')
              .onChange((value: string) => { this.email = value; });
          };
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: '#DDE7FF' });
      }
      .layoutWeight(1);

      // Bottom nav
      Row({ space: 12 }) {
        Button('上一步')
          .fontSize(15)
          .fontColor('#6B7280')
          .layoutWeight(1)
          .height(48)
          .borderRadius(12)
          .backgroundColor('#F3F4F6')
          .enabled(false)
          .opacity(0.4);

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
            holder.formData.name = this.name;
            holder.formData.photoUri = this.photoUri;
            holder.formData.phone = this.phone;
            holder.formData.email = this.email;
            router.pushUrl({ url: 'pages/StepExperience' });
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