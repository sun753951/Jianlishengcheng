import router from '@ohos.router';
import photoAccessHelper from '@ohos.file.photoAccessHelper';
import { ResumeDataHolder } from '../model/ResumeModels';
import { PRIMARY, PRIMARY_LIGHT, BG_PAGE, BORDER_DEFAULT } from '../style/Colors';

@Entry
@Component
struct StepBasicInfo {
  @State name: string = ResumeDataHolder.getInstance().formData.name;
  @State photoUri: string = ResumeDataHolder.getInstance().formData.photoUri;
  @State phone: string = ResumeDataHolder.getInstance().formData.phone;
  @State email: string = ResumeDataHolder.getInstance().formData.email;

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
              .backgroundColor(PRIMARY_LIGHT)
              .border({ width: 1, color: BORDER_DEFAULT })
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
              .fontColor(this.photoUri ? '#059669' : PRIMARY)
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
            Text('提示: 点击模拟器工具栏截图，截图存入图库后即可选择')
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
              .backgroundColor(PRIMARY_LIGHT)
              .border({ width: 1, color: BORDER_DEFAULT })
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
              .backgroundColor(PRIMARY_LIGHT)
              .border({ width: 1, color: BORDER_DEFAULT })
              .onChange((value: string) => { this.email = value; });
          };
        }
        .width('100%')
        .padding(16)
        .borderRadius(16)
        .backgroundColor('#FFFFFF')
        .border({ width: 1, color: BORDER_DEFAULT })
        .shadow({ radius: 12, color: 'rgba(0,0,0,0.07)', offsetY: 4 });
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
    .backgroundColor(BG_PAGE);
  }
}
