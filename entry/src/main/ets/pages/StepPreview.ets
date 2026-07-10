import router from '@ohos.router';
import { fileIo, picker } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import web_webview from '@ohos.web.webview';
import { socket, connection } from '@kit.NetworkKit';
import { DEMO_PHOTO_URI, ResumeDataHolder, ResumeFormData, ResumePreviewData, ResumePreviewSection, ResumeTemplateType } from '../model/ResumeModels';
import { requestScoreResume } from '../service/ResumeApiService';
import { scoreResume } from '../service/ResumeService';

@Entry
@Component
struct StepPreview {
  private holder: ResumeDataHolder = ResumeDataHolder.getInstance();

  @State previewData: ResumePreviewData = this.holder.previewData;
  @State generatedResume: string = this.holder.generatedResume;
  @State editedResume: string = this.holder.generatedResume;
  @State scoreValue: number = this.holder.scoreValue;
  @State scoreLevel: string = this.holder.scoreLevel;
  @State suggestions: string[] = this.holder.suggestions;
  @State selectedTemplate: ResumeTemplateType = this.holder.selectedTemplate;
  @State isScoring: boolean = false;
  @State isExporting: boolean = false;
  @State exportStatus: string = '';
  @State isSavingPdf: boolean = false;
  @State apiError: string = '';
  @State lastPdfPath: string = '';
  @State serverRunning: boolean = false;
  @State serverUrl: string = '';
  @State isRenderingPdf: boolean = false;
  @State webViewSrc: string = 'about:blank';

  private onPageEndPromise: (() => void) | null = null;
  private webController: web_webview.WebviewController = new web_webview.WebviewController();
  private tcpServer: socket.TCPSocketServer | undefined = undefined;
  private pdfDataCache: ArrayBuffer | undefined = undefined;

  aboutToDisappear(): void {
    this.stopHttpServer();
  }

  private isDemoPhoto(uri: string): boolean { return uri === DEMO_PHOTO_URI; }

  private accentColor(): string {
    const t: ResumeTemplateType = this.selectedTemplate;
    if (t === ResumeTemplateType.STANDARD) { return '#0F766E'; }
    if (t === ResumeTemplateType.TECHNICAL) { return '#1D4ED8'; }
    if (t === ResumeTemplateType.CAMPUS) { return '#7C3AED'; }
    if (t === ResumeTemplateType.EXECUTIVE) { return '#B45309'; }
    if (t === ResumeTemplateType.MINIMAL) { return '#374151'; }
    if (t === ResumeTemplateType.BLACK_GOLD) { return '#D4AF37'; }
    return '#1D4ED8';
  }

  private softColor(): string {
    const t: ResumeTemplateType = this.selectedTemplate;
    if (t === ResumeTemplateType.STANDARD) { return '#CCFBF1'; }
    if (t === ResumeTemplateType.TECHNICAL) { return '#DBEAFE'; }
    if (t === ResumeTemplateType.CAMPUS) { return '#EDE9FE'; }
    if (t === ResumeTemplateType.EXECUTIVE) { return '#FEF3C7'; }
    if (t === ResumeTemplateType.MINIMAL) { return '#F3F4F6'; }
    if (t === ResumeTemplateType.BLACK_GOLD) { return '#1F2937'; }
    return '#DBEAFE';
  }

  private async refreshScore(): Promise<void> {
    this.isScoring = true;
    this.apiError = '';
    try {
      const res = await requestScoreResume(this.holder.formData, this.selectedTemplate, this.editedResume);
      this.scoreValue = res.score; this.scoreLevel = res.level; this.suggestions = res.suggestions;
      this.holder.scoreValue = res.score; this.holder.scoreLevel = res.level; this.holder.suggestions = res.suggestions;
    } catch (_) {
      const local = scoreResume(this.holder.formData);
      this.scoreValue = local.score; this.scoreLevel = local.level; this.suggestions = local.suggestions;
      this.holder.scoreValue = local.score; this.holder.scoreLevel = local.level; this.holder.suggestions = local.suggestions;
      this.apiError = '评分服务不可用，已使用本地评分';
    } finally { this.isScoring = false; }
  }

  private async exportPdf(): Promise<void> {
    if (this.editedResume.trim().length === 0) {
      this.exportStatus = '请先生成简历后再预览';
      return;
    }
    this.isExporting = true;
    this.exportStatus = '正在生成 PDF...';
    let tmpPath: string = '';
    try {
      if (this.serverRunning) { this.stopHttpServer(); }

      this.isRenderingPdf = true;
      const html: string = await this.buildResumeHtml();
      const loadPromise: Promise<void> = new Promise<void>((resolve: () => void) => {
        this.onPageEndPromise = resolve;
      });
      this.webViewSrc = 'data:text/html;charset=UTF-8,' + encodeURIComponent(html);
      await loadPromise;

      const pdfConfig: web_webview.PdfConfiguration = {
        width: 8.27, height: 11.69,
        marginTop: 0.4, marginBottom: 0.4,
        marginLeft: 0.4, marginRight: 0.4,
        shouldPrintBackground: true
      };
      this.exportStatus = '正在渲染 PDF...';
      const pdfData: web_webview.PdfData = await this.webController.createPdf(pdfConfig);
      const pdfBuffer: ArrayBuffer = pdfData.pdfArrayBuffer().buffer as ArrayBuffer;
      this.pdfDataCache = pdfBuffer;

      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      tmpPath = `${context.filesDir}/resume_preview.pdf`;
      const tmpFile: fileIo.File = fileIo.openSync(tmpPath,
        fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.CREATE | fileIo.OpenMode.TRUNC);
      fileIo.writeSync(tmpFile.fd, pdfBuffer);
      fileIo.closeSync(tmpFile);
      this.lastPdfPath = tmpPath;
      this.isRenderingPdf = false;
      this.exportStatus = 'PDF 已生成，可保存到本地或发送到 PC';
    } catch (e) {
      this.isRenderingPdf = false;
      try { if (tmpPath.length > 0) { fileIo.unlinkSync(tmpPath); } } catch (_) { /* ignore */ }
      const msg: string = (typeof e === 'object' && e !== null)
        ? (e as Record<string, Object>)['message'] as string || `${e}`
        : `${e}`;
      if (msg.includes('canceled') || msg.includes('User cancel') || msg.includes('取消')) {
        this.exportStatus = '';
      } else {
        this.exportStatus = `生成失败: ${msg}`;
      }
    } finally { this.isExporting = false; }
  }

  private async savePdfToPublicDir(): Promise<void> {
    const srcPath: string = this.lastPdfPath;
    if (srcPath.length === 0 || !fileIo.accessSync(srcPath)) {
      this.exportStatus = '请先导出 PDF 后再保存到本地';
      return;
    }
    this.isSavingPdf = true;
    try {
      const documentSaveOptions: picker.DocumentSaveOptions = new picker.DocumentSaveOptions();
      documentSaveOptions.newFileNames = ['resume_preview.pdf'];
      const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
      const documentViewPicker: picker.DocumentViewPicker = new picker.DocumentViewPicker(context);
      const uris: Array<string> = await documentViewPicker.save(documentSaveOptions);
      if (uris.length === 0) {
        this.exportStatus = '已取消保存';
        return;
      }
      const srcFile: fileIo.File = fileIo.openSync(srcPath, fileIo.OpenMode.READ_ONLY);
      const destFile: fileIo.File = fileIo.openSync(uris[0],
        fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC);
      const buf: ArrayBuffer = new ArrayBuffer(4096);
      let readLen: number = fileIo.readSync(srcFile.fd, buf);
      while (readLen > 0) {
        fileIo.writeSync(destFile.fd, buf, { length: readLen });
        readLen = fileIo.readSync(srcFile.fd, buf);
      }
      fileIo.closeSync(srcFile);
      fileIo.closeSync(destFile);
      this.exportStatus = 'PDF 已保存，可在文件管理中查看';
    } catch (e) {
      const msg: string = (typeof e === 'object' && e !== null)
        ? (e as Record<string, Object>)['message'] as string || `${e}`
        : `${e}`;
      if (msg.includes('canceled') || msg.includes('User cancel') || msg.includes('取消')) {
        this.exportStatus = '';
      } else {
        this.exportStatus = `保存失败: ${msg}`;
      }
    } finally { this.isSavingPdf = false; }
  }

  private async getDeviceIp(): Promise<string> {
    try {
      const defaultNet: connection.NetHandle = await connection.getDefaultNet();
      const props = await connection.getConnectionProperties(defaultNet);
      const addrs = props.linkAddresses;
      for (let i: number = 0; i < addrs.length; i++) {
        const text: string = String(addrs[i]);
        const ip: string = this.extractIpv4(text);
        if (ip.length > 0 && ip !== '127.0.0.1') { return ip; }
      }
    } catch (_) { /* ignore */ }
    return '';
  }

  private extractIpv4(text: string): string {
    let ip: string = '';
    for (let i: number = 0; i < text.length; i++) {
      const ch: string = text.charAt(i);
      if ((ch >= '0' && ch <= '9') || ch === '.') {
        ip += ch;
        if (ip.length > 15) { return ''; }
      } else if (ip.length > 0) {
        if (this.countChar(ip, '.') === 3) { return ip; }
        return '';
      }
    }
    if (ip.length > 0 && this.countChar(ip, '.') === 3) { return ip; }
    return '';
  }

  private countChar(str: string, ch: string): number {
    let count: number = 0;
    for (let i: number = 0; i < str.length; i++) {
      if (str.charAt(i) === ch) { count++; }
    }
    return count;
  }

  private async startHttpServer(): Promise<void> {
    if (this.serverRunning) { this.stopHttpServer(); }
    if (this.pdfDataCache === undefined && this.lastPdfPath.length === 0) {
      this.exportStatus = '请先生成 PDF';
      return;
    }
    try {
      const pdfData: ArrayBuffer = this.pdfDataCache !== undefined
        ? this.pdfDataCache : this.readPdfFile();

      this.tcpServer = socket.constructTCPSocketServerInstance();
      const address: socket.NetAddress = {
        address: '0.0.0.0' as string, port: 8888 as number, family: 1 as number
      };
      await this.tcpServer.listen(address);

      this.tcpServer.on('connect', (client: socket.TCPSocketConnection) => {
        client.on('message', (_msg: socket.SocketMessageInfo) => {
          const httpHeader: string =
            'HTTP/1.1 200 OK\r\n' +
            'Content-Type: application/pdf\r\n' +
            'Content-Disposition: inline; filename="resume_preview.pdf"\r\n' +
            'Content-Length: ' + pdfData.byteLength + '\r\n' +
            'Cache-Control: no-store, no-cache, must-revalidate\r\n' +
            'Pragma: no-cache\r\nExpires: 0\r\n' +
            'Access-Control-Allow-Origin: *\r\nConnection: close\r\n\r\n';

          const headerBytes: ArrayBuffer = this.stringToArrayBuffer(httpHeader);
          const totalLen: number = headerBytes.byteLength + pdfData.byteLength;
          const combined: ArrayBuffer = new ArrayBuffer(totalLen);
          const combinedView: Uint8Array = new Uint8Array(combined);
          combinedView.set(new Uint8Array(headerBytes), 0);
          combinedView.set(new Uint8Array(pdfData), headerBytes.byteLength);
          client.send({ data: combined });
          client.close();
        });
      });

      this.serverRunning = true;
      const ip: string = await this.getDeviceIp();
      this.serverUrl = ip.length > 0
        ? `http://${ip}:8888  (或 http://localhost:8888)`
        : '端口 8888 — hdc fport 后访问 http://localhost:8888';
      this.exportStatus = '';
    } catch (e) {
      const msg: string = (typeof e === 'object' && e !== null)
        ? (e as Record<string, Object>)['message'] as string || `${e}` : `${e}`;
      this.exportStatus = `服务启动失败: ${msg}`;
    }
  }

  private stopHttpServer(): void {
    if (this.tcpServer !== undefined) {
      try { this.tcpServer.off('connect'); this.tcpServer.close(); } catch (_) { /* ignore */ }
      this.tcpServer = undefined;
    }
    this.serverRunning = false;
    this.serverUrl = '';
  }

  private readPdfFile(): ArrayBuffer {
    const srcPath: string = this.lastPdfPath;
    const stat: fileIo.Stat = fileIo.statSync(srcPath);
    const buf: ArrayBuffer = new ArrayBuffer(stat.size);
    const file: fileIo.File = fileIo.openSync(srcPath, fileIo.OpenMode.READ_ONLY);
    fileIo.readSync(file.fd, buf);
    fileIo.closeSync(file);
    return buf;
  }

  private stringToArrayBuffer(str: string): ArrayBuffer {
    const buf: ArrayBuffer = new ArrayBuffer(str.length);
    const view: Uint8Array = new Uint8Array(buf);
    for (let i: number = 0; i < str.length; i++) { view[i] = str.charCodeAt(i); }
    return buf;
  }

  private escapeHtml(text: string): string {
    return text.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
  }

  private async buildResumeHtml(): Promise<string> {
    const d: ResumeFormData = this.holder.formData;
    const accent: string = this.accentColor();
    const initials: string = d.name.length > 0 ? d.name.substring(0, 1) : '?';
    const photoHtml: string = await this.buildPhotoHtml(d.photoUri, initials);

    return '<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><style>' +
      '@page{size:A4;margin:0;}' +
      '*{margin:0;padding:0;box-sizing:border-box;}' +
      'body{font-family:PingFang SC,Microsoft YaHei,sans-serif;font-size:11pt;color:#333;line-height:1.6;}' +
      '.layout{display:flex;min-height:297mm;}' +
      '.sidebar{width:32%;background:' + accent + ';color:#fff;padding:28px 20px;}' +
      '.sidebar h2{font-size:16pt;margin-bottom:20px;border-bottom:1px solid rgba(255,255,255,0.3);padding-bottom:8px;}' +
      '.sidebar .item{margin-bottom:14px;font-size:9.5pt;line-height:1.5;}' +
      '.sidebar .label{font-size:8.5pt;opacity:0.8;margin-bottom:2px;}' +
      '.avatar{width:90px;height:90px;border-radius:50%;border:3px solid rgba(255,255,255,0.3);margin:0 auto 16px;display:flex;align-items:center;justify-content:center;overflow:hidden;}' +
      '.avatar img{width:100%;height:100%;object-fit:cover;}' +
      '.avatar-text{font-size:32pt;font-weight:bold;color:#fff;}' +
      '.main{width:68%;padding:28px 24px;}' +
      '.main h1{font-size:22pt;color:' + accent + ';margin-bottom:2px;}' +
      '.main h3{font-size:11pt;color:#555;font-weight:normal;margin-bottom:18px;}' +
      '.section{margin-bottom:16px;}' +
      '.s-title{font-size:12pt;font-weight:bold;color:' + accent + ';border-bottom:1.5px solid ' + accent + ';padding-bottom:3px;margin-bottom:8px;}' +
      '.s-content{font-size:10pt;line-height:1.7;white-space:pre-wrap;}' +
      '.skill-tag{display:inline-block;background:rgba(255,255,255,0.15);color:#fff;padding:3px 10px;border-radius:10px;margin:2px 4px 4px 0;font-size:9pt;}' +
      '</style></head><body><div class="layout">' +
      '<div class="sidebar">' +
      photoHtml +
      '<h2>个人信息</h2>' +
      '<div class="item"><div class="label">电话</div>' + this.escapeHtml(d.phone) + '</div>' +
      '<div class="item"><div class="label">邮箱</div>' + this.escapeHtml(d.email) + '</div>' +
      '<div class="item"><div class="label">求职意向</div>' + this.escapeHtml(d.targetPosition) + '</div>' +
      this.buildSidebarSkills(d.skills) +
      '</div>' +
      '<div class="main">' +
      '<h1>' + this.escapeHtml(d.name) + '</h1>' +
      '<h3>' + this.escapeHtml(d.targetPosition) + '</h3>' +
      this.buildSection('教育背景', d.education) +
      this.buildSection('工作经历', d.workExperience) +
      this.buildSection('项目经验', d.projectExperience) +
      this.buildSection('自我评价', d.selfEvaluation) +
      '</div></div></body></html>';
  }

  private async buildPhotoHtml(photoUri: string, initials: string): Promise<string> {
    if (photoUri === DEMO_PHOTO_URI || photoUri.length === 0) {
      return '<div class="avatar"><div class="avatar-text">' + this.escapeHtml(initials) + '</div></div>';
    }
    try {
      const dataUri: string = await this.readPhotoAsDataUri(photoUri);
      return '<div class="avatar"><img src="' + dataUri + '"/></div>';
    } catch (_) {
      return '<div class="avatar"><div class="avatar-text">' + this.escapeHtml(initials) + '</div></div>';
    }
  }

  private async readPhotoAsDataUri(uri: string): Promise<string> {
    const context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
    const file: fileIo.File = fileIo.openSync(uri, fileIo.OpenMode.READ_ONLY);
    const stat: fileIo.Stat = fileIo.statSync(uri);
    const buf: ArrayBuffer = new ArrayBuffer(stat.size);
    fileIo.readSync(file.fd, buf);
    fileIo.closeSync(file);
    const b64: string = this.arrayBufferToBase64(buf);
    return 'data:image/jpeg;base64,' + b64;
  }

  private arrayBufferToBase64(buffer: ArrayBuffer): string {
    const chars: string = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    const bytes: Uint8Array = new Uint8Array(buffer);
    let result: string = '';
    for (let i: number = 0; i < bytes.length; i += 3) {
      const b0: number = bytes[i];
      const b1: number = i + 1 < bytes.length ? bytes[i + 1] : 0;
      const b2: number = i + 2 < bytes.length ? bytes[i + 2] : 0;
      result += chars.charAt((b0 >> 2) & 63);
      result += chars.charAt(((b0 << 4) | (b1 >> 4)) & 63);
      result += chars.charAt(i + 1 < bytes.length ? ((b1 << 2) | (b2 >> 6)) & 63 : 64);
      result += chars.charAt(i + 2 < bytes.length ? b2 & 63 : 64);
    }
    return result;
  }

  private buildSidebarSkills(skills: string): string {
    const trimmed: string = skills.trim();
    if (trimmed.length === 0) { return ''; }
    let html: string = '<h2>专业技能</h2>';
    const tags: string[] = trimmed.split(new RegExp('[,，、\\n]+'));
    for (let i: number = 0; i < tags.length; i++) {
      const tag: string = tags[i].trim();
      if (tag.length > 0) {
        html += '<span class="skill-tag">' + this.escapeHtml(tag) + '</span>';
      }
    }
    return html;
  }

  private buildSection(title: string, content: string): string {
    const c: string = content.trim();
    if (c.length === 0) { return ''; }
    return '<div class="section"><div class="s-title">' + this.escapeHtml(title) + '</div><div class="s-content">' + this.escapeHtml(c) + '</div></div>';
  }

  @Builder stepIndicator(current: number) {
    Row({ space: 8 }) {
      ForEach([1, 2, 3, 4], (s: number) => {
        Circle({ width: 10, height: 10 }).fill(s <= current ? '#2563EB' : '#D1D5DB');
      });
    }.justifyContent(FlexAlign.Center).margin({ bottom: 20 });
  }

  @Builder photoBox(size: number, radius: number) {
    if (this.previewData.photoUri.length > 0) {
      if (this.isDemoPhoto(this.previewData.photoUri)) {
        Image($r('app.media.startIcon'))
          .width(size).height(size).borderRadius(radius).objectFit(ImageFit.Cover)
          .border({ width: 2, color: '#E0E7FF' });
      } else {
        Image(this.previewData.photoUri)
          .width(size).height(size).borderRadius(radius).objectFit(ImageFit.Cover)
          .border({ width: 2, color: '#E0E7FF' });
      }
    } else {
      Text(this.previewData.name.substring(0, 1))
        .fontSize(size * 0.42).fontWeight(FontWeight.Bold).fontColor('#FFFFFF')
        .textAlign(TextAlign.Center).width(size).height(size).borderRadius(radius)
        .backgroundColor('#6366F1');
    }
  }

  @Builder resumeSection(section: ResumePreviewSection) {
    Column({ space: 6 }) {
      Row({ space: 8 }) {
        Divider().vertical(true).height(18).strokeWidth(3).color(this.accentColor());
        Text(section.title).fontSize(15).fontWeight(FontWeight.Bold).fontColor('#111827');
      }.width('100%');
      Text(section.content).fontSize(13).fontColor('#1F2937').lineHeight(20).width('100%');
    }.alignItems(HorizontalAlign.Start).width('100%');
  }

  @Builder skillTag(tag: string) {
    Text(tag).fontSize(11).fontColor(this.accentColor()).fontWeight(FontWeight.Medium)
      .padding({ left: 9, right: 9, top: 5, bottom: 5 }).margin({ right: 8, bottom: 8 })
      .borderRadius(12).backgroundColor(this.softColor()).border({ width: 1, color: '#C7D2FE' });
  }

  @Builder standardResumePreview() {
    Column({ space: 14 }) {
      Row({ space: 14 }) {
        Column({ space: 5 }) {
          Text(this.previewData.name).fontSize(28).fontWeight(FontWeight.Bold).fontColor('#111827');
          Text(this.previewData.targetPosition).fontSize(14).fontColor('#374151');
          Text(`${this.previewData.phone}  |  ${this.previewData.email}`).fontSize(12).fontColor('#6B7280');
        }.alignItems(HorizontalAlign.Start).layoutWeight(1);
        this.photoBox(72, 6);
      }.width('100%');
      Divider().strokeWidth(1).color('#D1D5DB');
      Text(this.previewData.summary).fontSize(13).fontColor('#374151').lineHeight(20).width('100%');
      Column({ space: 12 }) {
        ForEach(this.previewData.mainSections,
          (s: ResumePreviewSection) => { this.resumeSection(s); },
          (s: ResumePreviewSection) => s.title);
      }.width('100%');
    }.width('100%').padding(18).borderRadius(16).backgroundColor('#FFFFFF')
     .border({ width: 1, color: '#A5B4FC' });
  }

  @Builder technicalResumePreview() {
    Column({ space: 0 }) {
      Column({ space: 8 }) {
        Row({ space: 12 }) {
          this.photoBox(58, 8);
          Column({ space: 4 }) {
            Text(this.previewData.name).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#FFFFFF');
            Text(this.previewData.targetPosition).fontSize(14).fontColor('#BFDBFE');
            Text(`${this.previewData.phone}  |  ${this.previewData.email}`).fontSize(11).fontColor('#93C5FD');
          }.alignItems(HorizontalAlign.Start).layoutWeight(1);
        }.width('100%');
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.previewData.skillTags, (t: string) => {
            Text(t).fontSize(11).fontWeight(FontWeight.Medium).fontColor('#DBEAFE')
              .padding({ left: 9, right: 9, top: 5, bottom: 5 }).margin({ right: 8, bottom: 8 })
              .borderRadius(12).backgroundColor('rgba(255,255,255,0.15)')
              .border({ width: 1, color: 'rgba(255,255,255,0.2)' });
          });
        }.width('100%');
        Text(this.previewData.summary).fontSize(12).fontColor('#DBEAFE').lineHeight(18).width('100%');
      }.width('100%').padding(16).backgroundColor('#1E3A8A');
      Column({ space: 12 }) {
        ForEach(this.previewData.mainSections, (s: ResumePreviewSection) => {
          Column({ space: 6 }) {
            Text(s.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1E3A8A');
            Text(s.content).fontSize(13).fontColor('#1F2937').lineHeight(20).width('100%');
          }.alignItems(HorizontalAlign.Start).width('100%').padding(12).borderRadius(12)
           .backgroundColor('#F8FAFF').border({ width: 1, color: '#C7D2FE' });
        }, (s: ResumePreviewSection) => s.title);
      }.width('100%').padding(16).backgroundColor('#FFFFFF');
    }.width('100%').borderRadius(16).clip(true).border({ width: 1, color: '#A5B4FC' });
  }

  @Builder campusResumePreview() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        this.photoBox(64, 32);
        Column({ space: 6 }) {
          Text(this.previewData.name).fontSize(26).fontWeight(FontWeight.Bold).fontColor('#4C1D95');
          Text(this.previewData.targetPosition).fontSize(14).fontColor('#7C3AED');
          Text(`${this.previewData.phone}  |  ${this.previewData.email}`).fontSize(12).fontColor('#6B7280');
        }.alignItems(HorizontalAlign.Start).layoutWeight(1);
      }.width('100%');
      Text(this.previewData.summary).fontSize(12).fontColor('#4B5563').lineHeight(18).width('100%');
      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.previewData.skillTags, (t: string) => { this.skillTag(t); });
      }.width('100%');
      Column({ space: 12 }) {
        ForEach(this.previewData.mainSections, (s: ResumePreviewSection) => {
          Column({ space: 5 }) {
            Text(s.title).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#7C3AED');
            Text(s.content).fontSize(13).fontColor('#1F2937').lineHeight(19).width('100%');
          }.alignItems(HorizontalAlign.Start).width('100%').padding(12).borderRadius(12)
           .backgroundColor('#F5F3FF').border({ width: 1, color: '#DDD6FE' });
        }, (s: ResumePreviewSection) => s.title);
      }.width('100%');
    }.width('100%').padding(18).borderRadius(16).backgroundColor('#FFFFFF')
     .border({ width: 1, color: '#DDD6FE' });
  }

  @Builder executiveResumePreview() {
    Column({ space: 14 }) {
      Row({ space: 12 }) {
        Column({ space: 4 }) {
          Text(this.previewData.name).fontSize(28).fontWeight(FontWeight.Bold).fontColor('#111827');
          Text(this.previewData.targetPosition).fontSize(13).fontColor('#92400E').fontWeight(FontWeight.Medium);
          Text(`${this.previewData.phone}  |  ${this.previewData.email}`).fontSize(11).fontColor('#6B7280');
        }.alignItems(HorizontalAlign.Start).layoutWeight(1);
        this.photoBox(68, 10);
      }.width('100%');
      Row().height(1).width('100%').backgroundColor('#D4AF37');
      Text(this.previewData.summary).fontSize(13).fontColor('#374151').lineHeight(20).width('100%')
        .padding({ top: 4, bottom: 4 });
      ForEach(this.previewData.mainSections, (s: ResumePreviewSection) => {
        Column({ space: 6 }) {
          Text(s.title).fontSize(13).fontWeight(FontWeight.Bold).fontColor('#92400E');
          Text(s.content).fontSize(12).fontColor('#1F2937').lineHeight(19).width('100%');
        }.alignItems(HorizontalAlign.Start).width('100%').padding(12).borderRadius(12)
         .backgroundColor('#FFFBEB').border({ width: 1, color: '#FDE68A' });
      }, (s: ResumePreviewSection) => s.title);
    }.width('100%').padding(18).borderRadius(16).backgroundColor('#FFFFFF')
     .border({ width: 1, color: '#D4AF37' });
  }

  @Builder minimalResumePreview() {
    Column({ space: 16 }) {
      Column({ space: 5 }) {
        Text(this.previewData.name).fontSize(30).fontWeight(FontWeight.Bold).fontColor('#111827');
        Text(this.previewData.targetPosition).fontSize(14).fontColor('#4B5563');
        Text(`${this.previewData.phone}  |  ${this.previewData.email}`).fontSize(11).fontColor('#6B7280');
      }.alignItems(HorizontalAlign.Start).width('100%');
      Row().height(1).width('100%').backgroundColor('#E5E7EB');
      Text(this.previewData.summary).fontSize(13).fontColor('#4B5563').lineHeight(20).width('100%');
      ForEach(this.previewData.mainSections, (s: ResumePreviewSection) => {
        Column({ space: 5 }) {
          Text(s.title).fontSize(13).fontWeight(FontWeight.Bold).fontColor('#374151');
          Text(s.content).fontSize(13).fontColor('#4B5563').lineHeight(20).width('100%');
        }.alignItems(HorizontalAlign.Start).width('100%');
      }, (s: ResumePreviewSection) => s.title);
    }.width('100%').padding(18).borderRadius(16).backgroundColor('#FFFFFF')
     .border({ width: 1, color: '#E5E7EB' });
  }

  @Builder blackGoldResumePreview() {
    Column({ space: 14 }) {
      Column({ space: 4 }) {
        Row({ space: 12 }) {
          Column({ space: 4 }) {
            Text(this.previewData.name).fontSize(28).fontWeight(FontWeight.Bold).fontColor('#FFFFFF');
            Text(this.previewData.targetPosition).fontSize(13).fontColor('#FCD34D');
            Text(`${this.previewData.phone}  |  ${this.previewData.email}`).fontSize(11).fontColor('#D1D5DB');
          }.alignItems(HorizontalAlign.Start).layoutWeight(1);
        }.width('100%');
      }.width('100%').padding(16).backgroundColor('#111827');
      Column({ space: 12 }) {
        Flex({ wrap: FlexWrap.Wrap }) {
          ForEach(this.previewData.skillTags, (t: string) => {
            Text(t).fontSize(11).fontWeight(FontWeight.Medium).fontColor('#111827')
              .padding({ left: 9, right: 9, top: 5, bottom: 5 }).margin({ right: 8, bottom: 8 })
              .borderRadius(12).backgroundColor('#FCD34D');
          });
        }.width('100%');
        Text(this.previewData.summary).fontSize(12).fontColor('#D1D5DB').lineHeight(18).width('100%');
        ForEach(this.previewData.mainSections, (s: ResumePreviewSection) => {
          Column({ space: 5 }) {
            Text(s.title).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#D4AF37');
            Text(s.content).fontSize(12).fontColor('#D1D5DB').lineHeight(18).width('100%');
          }.alignItems(HorizontalAlign.Start).width('100%');
        }, (s: ResumePreviewSection) => s.title);
      }.width('100%').padding(16).backgroundColor('#1F2937');
    }.width('100%').borderRadius(16).clip(true).border({ width: 1, color: '#D4AF37' });
  }

  @Builder resumePreviewCard() {
    if (this.selectedTemplate === ResumeTemplateType.STANDARD) { this.standardResumePreview(); }
    if (this.selectedTemplate === ResumeTemplateType.TECHNICAL) { this.technicalResumePreview(); }
    if (this.selectedTemplate === ResumeTemplateType.CAMPUS) { this.campusResumePreview(); }
    if (this.selectedTemplate === ResumeTemplateType.EXECUTIVE) { this.executiveResumePreview(); }
    if (this.selectedTemplate === ResumeTemplateType.MINIMAL) { this.minimalResumePreview(); }
    if (this.selectedTemplate === ResumeTemplateType.BLACK_GOLD) { this.blackGoldResumePreview(); }
  }

  @Builder scorePanel() {
    Column({ space: 12 }) {
      Row() {
        Column({ space: 4 }) {
          Text('简历评分').fontSize(18).fontWeight(FontWeight.Bold).fontColor('#064E3B');
          Text(this.scoreLevel).fontSize(13).fontColor('#047857');
        }.alignItems(HorizontalAlign.Start).layoutWeight(1);
        Text(`${this.scoreValue}`).fontSize(36).fontWeight(FontWeight.Bold).fontColor('#059669');
      }.width('100%');
      Progress({ value: this.scoreValue, total: 100, type: ProgressType.Linear })
        .width('100%').color('#16A34A').backgroundColor('#E5E7EB');
      ForEach(this.suggestions, (s: string) => {
        Text(`• ${s}`).fontSize(13).fontColor('#374151').lineHeight(20).width('100%');
      });
    }.width('100%').padding(16).borderRadius(14).backgroundColor('#ECFDF3')
     .border({ width: 1, color: '#A7F3D0' });
  }

  build() {
    Stack() {
      Column() {
        Scroll() {
          Column({ space: 14 }) {
            this.stepIndicator(4);

            Column({ space: 4 }) {
              Text('预览与导出').fontSize(20).fontWeight(FontWeight.Bold).fontColor('#111827');
              Text('第 4 步 / 共 4 步 — 预览简历、调整文本、评分并导出 PDF').fontSize(13).fontColor('#6B7280');
            }.alignItems(HorizontalAlign.Start).width('100%');

            Column({ space: 10 }) {
              Text('模板预览').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#111827').width('100%');
              if (this.generatedResume.length > 0) {
                this.resumePreviewCard();
              } else {
                Text('未检测到简历数据，请返回上一步重新生成。').fontSize(13).fontColor('#9CA3AF')
                  .width('100%').textAlign(TextAlign.Center).padding(20);
              }
            }.width('100%').padding(16).borderRadius(16).backgroundColor('#FFFFFF')
             .border({ width: 1, color: '#DDE7FF' });

            Column({ space: 10 }) {
              Text('在线编辑').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#111827').width('100%');
              TextArea({ text: this.editedResume, placeholder: '纯文本简历，方便复制修改' })
                .fontSize(14).fontColor('#111827').width('100%').height(140).borderRadius(12)
                .backgroundColor('#F8FAFF').padding(12).border({ width: 1, color: '#DDE7FF' })
                .onChange((v: string) => { this.editedResume = v; this.exportStatus = ''; });
            }.width('100%').padding(16).borderRadius(16).backgroundColor('#FFFFFF')
             .border({ width: 1, color: '#DDE7FF' });

            if (this.scoreValue > 0) { this.scorePanel(); }

            if (this.apiError.length > 0) {
              Text(this.apiError).fontSize(13).fontColor('#EF4444').width('100%')
                .textAlign(TextAlign.Center).padding(12).borderRadius(10).backgroundColor('#FEF2F2');
            }

            if (this.exportStatus.length > 0) {
              Text(this.exportStatus).fontSize(13).fontColor('#059669').width('100%')
                .textAlign(TextAlign.Center).padding(12).borderRadius(10).backgroundColor('#ECFDF5');
            }

            if (this.serverRunning) {
              Column({ space: 8 }) {
                Text('PC 下载地址（在电脑浏览器打开）').fontSize(13).fontWeight(FontWeight.Medium).fontColor('#1D4ED8');
                Text(this.serverUrl).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#2563EB')
                  .fontStyle(FontStyle.Italic);
                Text('确保 PC 已执行 hdc fport tcp:8888 tcp:8888').fontSize(11).fontColor('#6B7280');
              }.width('100%').padding(12).borderRadius(10)
               .backgroundColor('#EFF6FF').border({ width: 1, color: '#BFDBFE' });
            }

            Row({ space: 10 }) {
              Button(this.isScoring ? '评分中...' : '更新评分')
                .height(42).fontSize(14).fontColor('#3730A3').backgroundColor('#E0E7FF')
                .layoutWeight(1).borderRadius(12)
                .enabled(!this.isScoring).onClick(() => { this.refreshScore(); });
              Button(this.isExporting ? '生成中...' : '导出 PDF')
                .height(42).fontSize(14).fontColor('#FFFFFF').backgroundColor('#059669')
                .layoutWeight(1).borderRadius(12)
                .enabled(!this.isExporting).onClick(() => { this.exportPdf(); });
            }.width('100%');

            if (this.lastPdfPath.length > 0) {
              Row({ space: 10 }) {
                Button(this.isSavingPdf ? '保存中...' : '保存到本地')
                  .height(42).fontSize(14).fontColor('#1D4ED8').backgroundColor('#DBEAFE')
                  .layoutWeight(1).borderRadius(12)
                  .enabled(!this.isSavingPdf).onClick(() => { this.savePdfToPublicDir(); });
                Button(this.serverRunning ? '停止服务' : '发送到PC')
                  .height(42).fontSize(14)
                  .fontColor(this.serverRunning ? '#DC2626' : '#7C3AED')
                  .backgroundColor(this.serverRunning ? '#FEE2E2' : '#EDE9FE')
                  .layoutWeight(1).borderRadius(12)
                  .onClick(() => {
                    if (this.serverRunning) { this.stopHttpServer(); }
                    else { this.startHttpServer(); }
                  });
              }.width('100%');
            }
          }.padding(16);
        }.layoutWeight(1);

        Row({ space: 12 }) {
          Button('← 上一步').fontSize(15).fontColor('#6B7280').layoutWeight(1).height(48)
            .borderRadius(12).backgroundColor('#F3F4F6')
            .onClick(() => { router.back(); });
          Button('返回首页').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
            .layoutWeight(1).height(48).borderRadius(12).backgroundColor('#2563EB')
            .onClick(() => { this.holder.reset(); router.clear(); router.pushUrl({ url: 'pages/HomePage' }); });
        }.width('100%').padding(16).backgroundColor('#FFFFFF');
      }
      .width('100%').height('100%');

      if (this.isRenderingPdf) {
        Stack() {
          Web({ src: this.webViewSrc, controller: this.webController })
            .width('100%').height('100%')
            .backgroundColor('#FFFFFF')
            .onPageEnd(() => {
              if (this.onPageEndPromise !== null) {
                this.onPageEndPromise();
                this.onPageEndPromise = null;
              }
            });
          Column({ space: 14 }) {
            LoadingProgress().width(40).height(40).color('#2563EB');
            Text(this.exportStatus).fontSize(14).fontColor('#6B7280');
          }
          .width('100%').height('100%')
          .justifyContent(FlexAlign.Center)
          .backgroundColor('rgba(255,255,255,0.95)');
        }
        .width('100%').height('100%');
      }
    }
    .width('100%').height('100%').backgroundColor('#F8FAFC');
  }
}
