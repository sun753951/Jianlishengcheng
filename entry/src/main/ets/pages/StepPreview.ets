import router from '@ohos.router';
import { fileIo, picker } from '@kit.CoreFileKit';
import { common } from '@kit.AbilityKit';
import web_webview from '@ohos.web.webview';
import { socket, connection } from '@kit.NetworkKit';
import { DEMO_PHOTO_URI, ResumeDataHolder, ResumeFormData, ResumePreviewData, ResumePreviewSection, ResumeTemplateType } from '../model/ResumeModels';
import { requestScoreResume } from '../service/ResumeApiService';
import { scoreResume } from '../service/ResumeService';
import { PRIMARY, PRIMARY_DARK, PRIMARY_LIGHT, PRIMARY_BORDER, BG_PAGE, BORDER_DEFAULT } from '../style/Colors';

interface HtmlSection {
  title: string;
  content: string;
}

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
    switch (this.selectedTemplate) {
      case ResumeTemplateType.STANDARD: return this.buildStandardHtml();
      case ResumeTemplateType.TECHNICAL: return this.buildTechnicalHtml();
      case ResumeTemplateType.CAMPUS: return this.buildCampusHtml();
      case ResumeTemplateType.EXECUTIVE: return this.buildExecutiveHtml();
      case ResumeTemplateType.MINIMAL: return this.buildMinimalHtml();
      case ResumeTemplateType.BLACK_GOLD: return this.buildBlackGoldHtml();
      default: return this.buildStandardHtml();
    }
  }

  private async buildPhotoHtml(photoUri: string, initials: string, size: number = 90, borderRadius: number = 50): Promise<string> {
    if (photoUri === DEMO_PHOTO_URI || photoUri.length === 0) {
      return '<div style="width:' + size + 'px;height:' + size + 'px;border-radius:' + borderRadius + 'px;display:flex;align-items:center;justify-content:center;overflow:hidden;background:#6366F1;"><span style="font-size:' + (size * 0.4) + 'pt;font-weight:bold;color:#fff;">' + this.escapeHtml(initials) + '</span></div>';
    }
    try {
      const dataUri: string = await this.readPhotoAsDataUri(photoUri);
      return '<div style="width:' + size + 'px;height:' + size + 'px;border-radius:' + borderRadius + 'px;display:flex;align-items:center;justify-content:center;overflow:hidden;border:2px solid #E0E7FF;"><img src="' + dataUri + '" style="width:100%;height:100%;object-fit:cover;"/></div>';
    } catch (_) {
      return '<div style="width:' + size + 'px;height:' + size + 'px;border-radius:' + borderRadius + 'px;display:flex;align-items:center;justify-content:center;overflow:hidden;background:#6366F1;"><span style="font-size:' + (size * 0.4) + 'pt;font-weight:bold;color:#fff;">' + this.escapeHtml(initials) + '</span></div>';
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

  private parseSkillTags(skills: string): string[] {
    const trimmed: string = skills.trim();
    if (trimmed.length === 0) { return []; }
    return trimmed.split(new RegExp('[,，、\\n]+')).map((t: string) => t.trim()).filter((t: string): boolean => t.length > 0);
  }

  private async buildStandardHtml(): Promise<string> {
    const d: ResumeFormData = this.holder.formData;
    const initials: string = d.name.length > 0 ? d.name.substring(0, 1) : '?';
    const photoHtml: string = await this.buildPhotoHtml(d.photoUri, initials, 72, 6);
    const tags: string[] = this.parseSkillTags(d.skills);

    const rawSections: HtmlSection[] = [
      {title: '教育背景', content: d.education.trim()},
      {title: '工作经历', content: d.workExperience.trim()},
      {title: '项目经验', content: d.projectExperience.trim()},
    ];
    const sections: HtmlSection[] = [];
    for (let i: number = 0; i < rawSections.length; i++) {
      if (rawSections[i].content.length > 0) { sections.push(rawSections[i]); }
    }

    let sectionHtml: string = '';
    for (let i: number = 0; i < sections.length; i++) {
      sectionHtml += '<div style="page-break-inside:avoid;margin-bottom:14px;">' +
        '<div style="display:flex;align-items:center;margin-bottom:6px;">' +
        '<div style="width:3px;height:18px;background:#0F766E;border-radius:2px;margin-right:8px;"></div>' +
        '<span style="font-size:15px;font-weight:bold;color:#111827;">' + this.escapeHtml(sections[i].title) + '</span>' +
        '</div>' +
        '<div style="font-size:13px;color:#1F2937;line-height:20px;white-space:pre-wrap;">' + this.escapeHtml(sections[i].content) + '</div>' +
        '</div>';
    }

    let tagsHtml: string = '';
    for (let i: number = 0; i < tags.length; i++) {
      tagsHtml += '<span style="font-size:11px;font-weight:500;color:#0F766E;background:#CCFBF1;border:1px solid #C7D2FE;border-radius:12px;padding:5px 9px;margin-right:6px;margin-bottom:6px;">' + this.escapeHtml(tags[i]) + '</span>';
    }

    const summaryText: string = d.selfEvaluation.trim();
    let summaryHtml: string = '';
    if (summaryText.length > 0) {
      summaryHtml = '<div style="margin-bottom:14px;"><div style="font-size:13px;color:#374151;line-height:20px;white-space:pre-wrap;">' + this.escapeHtml(summaryText) + '</div></div>';
    }

    return '<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><style>' +
      '@page{size:A4;margin:0;}' +
      '*{margin:0;padding:0;box-sizing:border-box;}' +
      'body{font-family:\'PingFang SC\',\'Microsoft YaHei\',sans-serif;background:#FFFFFF;padding:24px 28px;-webkit-print-color-adjust:exact;print-color-adjust:exact;}' +
      '</style></head><body>' +
      '<div style="display:flex;align-items:flex-start;margin-bottom:14px;">' +
      '<div style="flex:1;">' +
      '<div style="font-size:28px;font-weight:bold;color:#111827;">' + this.escapeHtml(d.name) + '</div>' +
      '<div style="font-size:14px;color:#374151;margin-top:2px;">' + this.escapeHtml(d.targetPosition) + '</div>' +
      '<div style="font-size:12px;color:#6B7280;margin-top:4px;">' + this.escapeHtml(d.phone) + ' | ' + this.escapeHtml(d.email) + '</div>' +
      '</div>' +
      photoHtml +
      '</div>' +
      '<hr style="border:none;border-top:1px solid #D1D5DB;margin-bottom:14px;"/>' +
      summaryHtml +
      sectionHtml +
      (tags.length > 0 ? '<div style="display:flex;flex-wrap:wrap;gap:6px;margin-top:4px;">' + tagsHtml + '</div>' : '') +
      '</body></html>';
  }

  private async buildTechnicalHtml(): Promise<string> {
    const d: ResumeFormData = this.holder.formData;
    const initials: string = d.name.length > 0 ? d.name.substring(0, 1) : '?';
    const photoHtml: string = await this.buildPhotoHtml(d.photoUri, initials, 58, 8);
    const tags: string[] = this.parseSkillTags(d.skills);

    let tagsHtml: string = '';
    for (let i: number = 0; i < tags.length; i++) {
      tagsHtml += '<span style="display:inline-block;font-size:11px;color:#DBEAFE;background:rgba(255,255,255,0.15);border:1px solid rgba(255,255,255,0.2);border-radius:12px;padding:5px 9px;margin-right:6px;margin-bottom:6px;">' + this.escapeHtml(tags[i]) + '</span>';
    }

    let sidebarHtml: string = '';
    for (let i: number = 0; i < this.previewData.sidebarSections.length; i++) {
      const s: ResumePreviewSection = this.previewData.sidebarSections[i];
      sidebarHtml += '<div style="margin-bottom:10px;">' +
        '<div style="font-size:12px;font-weight:bold;color:#BFDBFE;margin-bottom:3px;">' + this.escapeHtml(s.title) + '</div>' +
        '<div style="font-size:11px;color:#93C5FD;line-height:16px;white-space:pre-wrap;">' + this.escapeHtml(s.content) + '</div>' +
        '</div>';
    }

    let mainHtml: string = '';
    for (let i: number = 0; i < this.previewData.mainSections.length; i++) {
      const s: ResumePreviewSection = this.previewData.mainSections[i];
      mainHtml += '<div style="page-break-inside:avoid;background:#F8FAFF;border:1px solid #C7D2FE;border-radius:12px;padding:12px;margin-bottom:10px;">' +
        '<div style="font-size:16px;font-weight:bold;color:#1E3A8A;margin-bottom:6px;">' + this.escapeHtml(s.title) + '</div>' +
        '<div style="font-size:13px;color:#1F2937;line-height:20px;white-space:pre-wrap;">' + this.escapeHtml(s.content) + '</div>' +
        '</div>';
    }

    return '<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><style>' +
      '@page{size:A4;margin:0;}' +
      '*{margin:0;padding:0;box-sizing:border-box;}' +
      'body{font-family:\'PingFang SC\',\'Microsoft YaHei\',sans-serif;background:#FFF;-webkit-print-color-adjust:exact;print-color-adjust:exact;}' +
      '</style></head><body>' +
      '<div style="background:#1E3A8A;padding:16px 24px;">' +
      '<div style="font-size:24px;font-weight:bold;color:#FFF;">' + this.escapeHtml(d.name) + '</div>' +
      '<div style="font-size:14px;color:#BFDBFE;">' + this.escapeHtml(d.targetPosition) + '</div>' +
      '<div style="font-size:11px;color:#93C5FD;">' + this.escapeHtml(d.phone) + ' | ' + this.escapeHtml(d.email) + '</div>' +
      '</div>' +
      '<div style="display:flex;">' +
      '<div style="width:35%;background:#1E3A8A;padding:16px;">' +
      '<div style="text-align:center;">' + photoHtml + '</div>' +
      '<hr style="border-color:rgba(255,255,255,0.2);margin:10px 0;">' +
      '<div style="font-size:12px;font-weight:bold;color:#BFDBFE;margin-bottom:6px;">技能</div>' +
      '<div style="display:flex;flex-wrap:wrap;gap:6px;margin:6px 0;">' + tagsHtml + '</div>' +
      '<hr style="border-color:rgba(255,255,255,0.2);margin:10px 0;">' +
      sidebarHtml +
      '</div>' +
      '<div style="flex:1;padding:16px;background:#FFF;">' +
      '<div style="font-size:12px;color:#374151;line-height:18px;margin-bottom:12px;white-space:pre-wrap;">' + this.escapeHtml(this.previewData.summary) + '</div>' +
      mainHtml +
      '</div>' +
      '</div>' +
      '</body></html>';
  }

  private async buildCampusHtml(): Promise<string> {
    const d: ResumeFormData = this.holder.formData;
    const initials: string = d.name.length > 0 ? d.name.substring(0, 1) : '?';
    const photoHtml: string = await this.buildPhotoHtml(d.photoUri, initials, 64, 32);
    const tags: string[] = this.parseSkillTags(d.skills);

    let tagsHtml: string = '';
    for (let i: number = 0; i < tags.length; i++) {
      tagsHtml += '<span style="display:inline-block;font-size:11px;font-weight:500;color:#7C3AED;background:#EDE9FE;border:1px solid #C7D2FE;border-radius:12px;padding:5px 9px;margin-right:8px;margin-bottom:8px;">' + this.escapeHtml(tags[i]) + '</span>';
    }

    const mergedSections: ResumePreviewSection[] = [];
    for (let i: number = 0; i < this.previewData.sidebarSections.length; i++) {
      mergedSections.push(this.previewData.sidebarSections[i]);
    }
    for (let i: number = 0; i < this.previewData.mainSections.length; i++) {
      mergedSections.push(this.previewData.mainSections[i]);
    }

    let timelineHtml: string = '';
    for (let i: number = 0; i < mergedSections.length; i++) {
      const s: ResumePreviewSection = mergedSections[i];
      const isLast: boolean = i === mergedSections.length - 1;
      timelineHtml += '<div class="timeline-item page-break" style="display:flex;">' +
        '<div style="display:flex;flex-direction:column;align-items:center;width:16px;flex-shrink:0;">' +
        '<div style="width:8px;height:8px;border-radius:50%;background:#7C3AED;flex-shrink:0;margin-top:4px;"></div>' +
        (isLast ? '' : '<div style="margin-left:0;width:2px;flex-grow:1;background:#DDD6FE;"></div>') +
        '</div>' +
        '<div style="flex:1;padding:0 0 16px 12px;">' +
        '<div style="font-size:14px;font-weight:bold;color:#7C3AED;margin-bottom:4px;">' + this.escapeHtml(s.title) + '</div>' +
        '<div style="font-size:13px;color:#1F2937;line-height:19px;white-space:pre-wrap;">' + this.escapeHtml(s.content) + '</div>' +
        '</div>' +
        '</div>';
    }

    return '<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><style>' +
      '@page{size:A4;margin:0;}' +
      '*{margin:0;padding:0;box-sizing:border-box;}' +
      'body{font-family:\'PingFang SC\',\'Microsoft YaHei\',sans-serif;background:#FFF;padding:24px 28px;-webkit-print-color-adjust:exact;print-color-adjust:exact;}' +
      '</style></head><body>' +
      '<div style="display:flex;align-items:flex-start;gap:12px;background:#F5F3FF;border:1px solid #DDD6FE;border-radius:14px;padding:14px;margin-bottom:14px;">' +
      photoHtml +
      '<div style="flex:1;">' +
      '<div style="font-size:26px;font-weight:bold;color:#4C1D95;">' + this.escapeHtml(d.name) + '</div>' +
      '<div style="font-size:14px;color:#7C3AED;">' + this.escapeHtml(d.targetPosition) + '</div>' +
      '<div style="font-size:12px;color:#6B7280;">' + this.escapeHtml(d.phone) + ' | ' + this.escapeHtml(d.email) + '</div>' +
      '</div>' +
      '</div>' +
      '<div style="font-size:12px;color:#4B5563;line-height:18px;margin-bottom:14px;white-space:pre-wrap;">' + this.escapeHtml(this.previewData.summary) + '</div>' +
      (tags.length > 0 ? '<div style="display:flex;flex-wrap:wrap;gap:8px;margin-bottom:14px;">' + tagsHtml + '</div>' : '') +
      timelineHtml +
      '</body></html>';
  }

  private async buildExecutiveHtml(): Promise<string> {
    const d: ResumeFormData = this.holder.formData;

    let gridHtml: string = '';
    for (let i: number = 0; i < this.previewData.mainSections.length; i++) {
      const s: ResumePreviewSection = this.previewData.mainSections[i];
      gridHtml += '<div class="grid-item page-break" style="width:calc(50% - 5px);background:#FFFBEB;border:1px solid #FDE68A;border-radius:12px;padding:12px;">' +
        '<div style="font-size:13px;font-weight:bold;color:#92400E;margin-bottom:4px;">' + this.escapeHtml(s.title) + '</div>' +
        '<div style="font-size:12px;color:#1F2937;line-height:19px;white-space:pre-wrap;">' + this.escapeHtml(s.content) + '</div>' +
        '</div>';
    }

    return '<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><style>' +
      '@page{size:A4;margin:0;}' +
      '*{margin:0;padding:0;box-sizing:border-box;}' +
      'body{font-family:\'PingFang SC\',\'Microsoft YaHei\',sans-serif;background:#FFF;padding:24px 28px;-webkit-print-color-adjust:exact;print-color-adjust:exact;}' +
      '</style></head><body>' +
      '<div style="text-align:center;">' +
      '<div style="font-size:28px;font-weight:bold;color:#111827;">' + this.escapeHtml(d.name) + '</div>' +
      '<div style="font-size:13px;font-weight:500;color:#92400E;margin-top:2px;">' + this.escapeHtml(d.targetPosition) + '</div>' +
      '<div style="font-size:11px;color:#6B7280;margin-top:3px;">' + this.escapeHtml(d.phone) + ' | ' + this.escapeHtml(d.email) + '</div>' +
      '</div>' +
      '<hr style="border:none;border-top:2px solid #B45309;margin:14px 0;">' +
      '<div style="font-size:13px;color:#374151;line-height:20px;margin-bottom:14px;white-space:pre-wrap;">' + this.escapeHtml(this.previewData.summary) + '</div>' +
      '<div style="display:flex;flex-wrap:wrap;gap:10px;">' +
      gridHtml +
      '</div>' +
      '</body></html>';
  }

  private async buildMinimalHtml(): Promise<string> {
    const d: ResumeFormData = this.holder.formData;

    const summaryText: string = d.selfEvaluation.trim();
    let summaryHtml: string = '';
    if (summaryText.length > 0) {
      summaryHtml = '<div style="font-size:13px;color:#4B5563;line-height:20px;white-space:pre-wrap;margin-bottom:14px;">' + this.escapeHtml(summaryText) + '</div>';
    }

    const rawSections: HtmlSection[] = [
      {title: '教育背景', content: d.education.trim()},
      {title: '工作经历', content: d.workExperience.trim()},
      {title: '项目经验', content: d.projectExperience.trim()},
    ];
    const sections: HtmlSection[] = [];
    for (let i: number = 0; i < rawSections.length; i++) {
      if (rawSections[i].content.length > 0) { sections.push(rawSections[i]); }
    }

    let sectionHtml: string = '';
    for (let i: number = 0; i < sections.length; i++) {
      sectionHtml += '<div style="page-break-inside:avoid;margin-bottom:12px;">' +
        '<div style="font-size:13px;font-weight:bold;color:#374151;margin-bottom:3px;">' + this.escapeHtml(sections[i].title) + '</div>' +
        '<div style="font-size:13px;color:#4B5563;line-height:20px;white-space:pre-wrap;">' + this.escapeHtml(sections[i].content) + '</div>' +
        '</div>';
    }

    return '<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><style>' +
      '@page{size:A4;margin:0;}' +
      '*{margin:0;padding:0;box-sizing:border-box;}' +
      'body{font-family:\'PingFang SC\',\'Microsoft YaHei\',sans-serif;background:#FFFFFF;padding:24px 28px;-webkit-print-color-adjust:exact;print-color-adjust:exact;}' +
      '</style></head><body>' +
      '<div style="font-size:30px;font-weight:bold;color:#111827;">' + this.escapeHtml(d.name) + '</div>' +
      '<div style="font-size:14px;color:#4B5563;margin-top:2px;">' + this.escapeHtml(d.targetPosition) + '</div>' +
      '<div style="font-size:11px;color:#6B7280;margin-top:3px;">' + this.escapeHtml(d.phone) + ' | ' + this.escapeHtml(d.email) + '</div>' +
      '<hr style="border:none;border-top:1px solid #E5E7EB;margin:14px 0;"/>' +
      summaryHtml +
      sectionHtml +
      '</body></html>';
  }

  private async buildBlackGoldHtml(): Promise<string> {
    const d: ResumeFormData = this.holder.formData;
    const initials: string = d.name.length > 0 ? d.name.substring(0, 1) : '?';
    const photoHtml: string = await this.buildPhotoHtml(d.photoUri, initials, 62, 31);
    const tags: string[] = this.parseSkillTags(d.skills);

    let tagsHtml: string = '';
    for (let i: number = 0; i < tags.length; i++) {
      tagsHtml += '<span style="display:inline-block;font-size:10px;color:#111827;background:#FCD34D;border-radius:10px;padding:4px 7px;margin-right:5px;margin-bottom:5px;">' + this.escapeHtml(tags[i]) + '</span>';
    }

    let sidebarHtml: string = '';
    for (let i: number = 0; i < this.previewData.sidebarSections.length; i++) {
      const s: ResumePreviewSection = this.previewData.sidebarSections[i];
      if (s.title !== 'SKILLS') {
        sidebarHtml += '<div style="margin-bottom:12px;">' +
          '<div style="font-size:11px;font-weight:bold;color:#D4AF37;margin-bottom:3px;">' + this.escapeHtml(s.title) + '</div>' +
          '<div style="font-size:10px;color:#D1D5DB;line-height:15px;white-space:pre-wrap;">' + this.escapeHtml(s.content) + '</div>' +
          '</div>';
      }
    }

    let mainHtml: string = '';
    for (let i: number = 0; i < this.previewData.mainSections.length; i++) {
      const s: ResumePreviewSection = this.previewData.mainSections[i];
      mainHtml += '<div class="page-break" style="margin-bottom:14px;">' +
        '<div style="font-size:13px;font-weight:bold;color:#D4AF37;margin-bottom:3px;">' + this.escapeHtml(s.title) + '</div>' +
        '<div style="font-size:12px;color:#D1D5DB;line-height:18px;white-space:pre-wrap;">' + this.escapeHtml(s.content) + '</div>' +
        '</div>';
    }

    return '<!DOCTYPE html><html lang="zh-CN"><head><meta charset="UTF-8"><style>' +
      '@page{size:A4;margin:0;}' +
      '*{margin:0;padding:0;box-sizing:border-box;}' +
      'body{font-family:\'PingFang SC\',\'Microsoft YaHei\',sans-serif;background:#1F2937;-webkit-print-color-adjust:exact;print-color-adjust:exact;}' +
      '</style></head><body>' +
      '<div style="background:#111827;padding:14px 24px;">' +
      '<div style="display:flex;align-items:flex-start;gap:12px;">' +
      photoHtml +
      '<div style="flex:1;">' +
      '<div style="font-size:28px;font-weight:bold;color:#FFF;">' + this.escapeHtml(d.name) + '</div>' +
      '<div style="font-size:13px;color:#FCD34D;">' + this.escapeHtml(d.targetPosition) + '</div>' +
      '<div style="font-size:11px;color:#D1D5DB;">' + this.escapeHtml(d.phone) + ' | ' + this.escapeHtml(d.email) + '</div>' +
      '</div>' +
      '</div>' +
      '</div>' +
      '<div style="display:flex;background:#1F2937;">' +
      '<div style="width:35%;padding:16px;border-right:1px solid rgba(212,175,55,0.3);">' +
      sidebarHtml +
      '<div style="font-size:11px;font-weight:bold;color:#D4AF37;margin-top:12px;">SKILLS</div>' +
      '<div style="display:flex;flex-wrap:wrap;gap:5px;margin-top:6px;">' + tagsHtml + '</div>' +
      '</div>' +
      '<div style="flex:1;padding:16px;">' +
      mainHtml +
      '</div>' +
      '</div>' +
      '</body></html>';
  }

  @Builder stepIndicator(current: number) {
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

  @Builder photoBox(size: number, radius: number) {
    if (this.previewData.photoUri.length > 0) {
      if (this.isDemoPhoto(this.previewData.photoUri)) {
        Image($r('app.media.startIcon'))
          .width(size).height(size).borderRadius(radius).objectFit(ImageFit.Cover)
          .border({ width: 2, color: BORDER_DEFAULT });
      } else {
        Image(this.previewData.photoUri)
          .width(size).height(size).borderRadius(radius).objectFit(ImageFit.Cover)
          .border({ width: 2, color: BORDER_DEFAULT });
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
      .borderRadius(12).backgroundColor(this.softColor()).border({ width: 1, color: PRIMARY_BORDER });
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
     .border({ width: 1, color: '#CBD5E1' });
  }

  @Builder technicalResumePreview() {
    Column({ space: 0 }) {
      Row() {
        Column({ space: 4 }) {
          Text(this.previewData.name).fontSize(24).fontWeight(FontWeight.Bold).fontColor('#FFFFFF');
          Text(this.previewData.targetPosition).fontSize(14).fontColor('#BFDBFE');
          Text(`${this.previewData.phone} \uFF5C ${this.previewData.email}`).fontSize(11).fontColor('#93C5FD');
        }.alignItems(HorizontalAlign.Start).layoutWeight(1);
      }.width('100%').padding(16).backgroundColor('#1E3A8A');

      Row() {
        Column({ space: 10 }) {
          this.photoBox(58, 8);
          Row().width('100%').height(1).backgroundColor('rgba(255,255,255,0.2)');
          Text('技能').fontSize(12).fontWeight(FontWeight.Bold).fontColor('#BFDBFE');
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.previewData.skillTags, (t: string) => {
              Text(t).fontSize(11).fontColor('#DBEAFE')
                .padding({ left: 9, right: 9, top: 5, bottom: 5 }).margin({ right: 6, bottom: 6 })
                .borderRadius(12).backgroundColor('rgba(255,255,255,0.15)')
                .border({ width: 1, color: 'rgba(255,255,255,0.2)' });
            }, (t: string) => t);
          }.width('100%');
          Row().width('100%').height(1).backgroundColor('rgba(255,255,255,0.2)');
          ForEach(this.previewData.sidebarSections, (s: ResumePreviewSection) => {
            Column({ space: 3 }) {
              Text(s.title).fontSize(12).fontWeight(FontWeight.Bold).fontColor('#BFDBFE');
              Text(s.content).fontSize(11).fontColor('#93C5FD').lineHeight(16).width('100%');
            }.alignItems(HorizontalAlign.Start).width('100%');
          }, (s: ResumePreviewSection) => s.title);
        }.alignItems(HorizontalAlign.Start).width('35%').padding(12).backgroundColor('#1E3A8A');

        Column({ space: 12 }) {
          Text(this.previewData.summary).fontSize(12).fontColor('#374151').lineHeight(18).width('100%');
          ForEach(this.previewData.mainSections, (s: ResumePreviewSection) => {
            Column({ space: 6 }) {
              Text(s.title).fontSize(16).fontWeight(FontWeight.Bold).fontColor('#1E3A8A');
              Text(s.content).fontSize(13).fontColor('#1F2937').lineHeight(20).width('100%');
            }.alignItems(HorizontalAlign.Start).width('100%').padding(12).borderRadius(12)
             .backgroundColor('#F8FAFF').border({ width: 1, color: '#C7D2FE' });
          }, (s: ResumePreviewSection) => s.title);
        }.layoutWeight(1).padding(14).backgroundColor('#FFFFFF');
      }.width('100%');
    }.width('100%').borderRadius(16).clip(true).border({ width: 1, color: '#A5B4FC' })
     .backgroundColor('#FFFFFF');
  }

  private getMergedCampusSections(): ResumePreviewSection[] {
    const allSections: ResumePreviewSection[] = [];
    for (let i: number = 0; i < this.previewData.sidebarSections.length; i++) {
      allSections.push(this.previewData.sidebarSections[i]);
    }
    for (let i: number = 0; i < this.previewData.mainSections.length; i++) {
      allSections.push(this.previewData.mainSections[i]);
    }
    return allSections;
  }

  @Builder campusResumePreview() {
    Column({ space: 12 }) {
      Row({ space: 12 }) {
        this.photoBox(64, 32);
        Column({ space: 6 }) {
          Text(this.previewData.name).fontSize(26).fontWeight(FontWeight.Bold).fontColor('#4C1D95');
          Text(this.previewData.targetPosition).fontSize(14).fontColor('#7C3AED');
          Text(`${this.previewData.phone} \uFF5C ${this.previewData.email}`).fontSize(12).fontColor('#6B7280');
        }.alignItems(HorizontalAlign.Start).layoutWeight(1);
      }.width('100%').padding(14).borderRadius(14)
       .backgroundColor('#F5F3FF').border({ width: 1, color: '#DDD6FE' });

      Text(this.previewData.summary).fontSize(12).fontColor('#4B5563').lineHeight(18).width('100%');

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.previewData.skillTags, (t: string) => { this.skillTag(t); });
      }.width('100%');

      Column({ space: 0 }) {
        ForEach(this.getMergedCampusSections(), (s: ResumePreviewSection, idx: number) => {
          Row({ space: 8 }) {
            Column() {
              Circle().width(8).height(8).fill('#7C3AED');
              if (idx < this.getMergedCampusSections().length - 1) {
                Column().width(2).height(40).backgroundColor('#DDD6FE');
              }
            }.alignItems(HorizontalAlign.Center).width(20);

            Column({ space: 5 }) {
              Text(s.title).fontSize(14).fontWeight(FontWeight.Bold).fontColor('#7C3AED');
              Text(s.content).fontSize(13).fontColor('#1F2937').lineHeight(19).width('100%');
            }.alignItems(HorizontalAlign.Start).layoutWeight(1).padding({ bottom: 16 });
          }.width('100%').alignItems(VerticalAlign.Top);
        }, (s: ResumePreviewSection, idx: number) => `${idx}_${s.title}`);
      }.width('100%');
    }.width('100%').padding(18).borderRadius(16).backgroundColor('#FFFFFF')
     .border({ width: 1, color: '#DDD6FE' });
  }

  @Builder executiveResumePreview() {
    Column({ space: 14 }) {
      Column({ space: 4 }) {
        Text(this.previewData.name).fontSize(28).fontWeight(FontWeight.Bold).fontColor('#111827');
        Text(this.previewData.targetPosition).fontSize(13).fontColor('#92400E').fontWeight(FontWeight.Medium);
        Text(`${this.previewData.phone} \uFF5C ${this.previewData.email}`).fontSize(11).fontColor('#6B7280');
      }.alignItems(HorizontalAlign.Center).width('100%');

      Row().height(2).width('100%').backgroundColor('#B45309').borderRadius(2);

      Text(this.previewData.summary).fontSize(13).fontColor('#374151').lineHeight(20).width('100%');

      Flex({ wrap: FlexWrap.Wrap }) {
        ForEach(this.previewData.mainSections, (s: ResumePreviewSection) => {
          Column({ space: 5 }) {
            Text(s.title).fontSize(13).fontWeight(FontWeight.Bold).fontColor('#92400E');
            Text(s.content).fontSize(12).fontColor('#1F2937').lineHeight(19).width('100%');
          }.alignItems(HorizontalAlign.Start).width('48%').padding(10).borderRadius(12)
           .backgroundColor('#FFFBEB').border({ width: 1, color: '#FDE68A' })
           .margin({ right: '2%', bottom: 10 });
        }, (s: ResumePreviewSection) => s.title);
      }.width('100%');
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
      Divider().strokeWidth(1).color('#E5E7EB');
      Text(this.previewData.summary).fontSize(13).fontColor('#4B5563').lineHeight(20).width('100%');
      ForEach(this.previewData.mainSections, (s: ResumePreviewSection) => {
        Column({ space: 6 }) {
          Text(s.title).fontSize(13).fontWeight(FontWeight.Bold).fontColor('#374151');
          Text(s.content).fontSize(13).fontColor('#4B5563').lineHeight(20).width('100%');
        }.alignItems(HorizontalAlign.Start).width('100%');
      }, (s: ResumePreviewSection) => s.title);
    }.width('100%').padding(18).borderRadius(16).backgroundColor('#FFFFFF')
     .border({ width: 1, color: '#E5E7EB' });
  }

  @Builder blackGoldResumePreview() {
    Column({ space: 0 }) {
      Column({ space: 0 }) {
        Row({ space: 12 }) {
          this.photoBox(62, 31);
          Column({ space: 4 }) {
            Text(this.previewData.name).fontSize(28).fontWeight(FontWeight.Bold).fontColor('#F9FAFB');
            Text(this.previewData.targetPosition).fontSize(13).fontColor('#FCD34D');
            Text(`${this.previewData.phone} \uFF5C ${this.previewData.email}`).fontSize(11).fontColor('#D1D5DB');
          }.alignItems(HorizontalAlign.Start).layoutWeight(1);
        }.width('100%');
      }.width('100%').padding(14).backgroundColor('#111827');

      Row() {
        Column({ space: 12 }) {
          ForEach(this.previewData.sidebarSections, (s: ResumePreviewSection) => {
            if (s.title !== 'SKILLS') {
              Column({ space: 3 }) {
                Text(s.title).fontSize(11).fontWeight(FontWeight.Bold).fontColor('#D4AF37');
                Text(s.content).fontSize(10).fontColor('#D1D5DB').lineHeight(15).width('100%');
              }.alignItems(HorizontalAlign.Start).width('100%');
            }
          }, (s: ResumePreviewSection) => s.title);

          Text('SKILLS').fontSize(11).fontWeight(FontWeight.Bold).fontColor('#D4AF37');
          Flex({ wrap: FlexWrap.Wrap }) {
            ForEach(this.previewData.skillTags, (t: string) => {
              Text(t).fontSize(10).fontColor('#111827')
                .padding({ left: 7, right: 7, top: 4, bottom: 4 }).margin({ right: 5, bottom: 5 })
                .borderRadius(10).backgroundColor('#FCD34D');
            }, (t: string) => t);
          }.width('100%');
        }.alignItems(HorizontalAlign.Start).width('35%').padding(14);

        Column().width(1).backgroundColor('rgba(212,175,55,0.3)');

        Column({ space: 12 }) {
          ForEach(this.previewData.mainSections, (s: ResumePreviewSection) => {
            Column({ space: 4 }) {
              Text(s.title).fontSize(13).fontWeight(FontWeight.Bold).fontColor('#D4AF37');
              Text(s.content).fontSize(12).fontColor('#D1D5DB').lineHeight(18).width('100%');
            }.alignItems(HorizontalAlign.Start).width('100%');
          }, (s: ResumePreviewSection) => s.title);
        }.layoutWeight(1).padding(14);
      }.width('100%').backgroundColor('#1F2937');
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
          Text('简历评分').fontSize(18).fontWeight(FontWeight.Bold).fontColor(PRIMARY_DARK);
          Text(this.scoreLevel).fontSize(13).fontColor(PRIMARY);
        }.alignItems(HorizontalAlign.Start).layoutWeight(1);
        Text(`${this.scoreValue}`).fontSize(36).fontWeight(FontWeight.Bold).fontColor(PRIMARY);
      }.width('100%');
      Progress({ value: this.scoreValue, total: 100, type: ProgressType.Linear })
        .width('100%').color(PRIMARY).backgroundColor('#E5E7EB');
      ForEach(this.suggestions, (s: string) => {
        Text(`\u2022 ${s}`).fontSize(13).fontColor('#374151').lineHeight(20).width('100%');
      });
    }.width('100%').padding(16).borderRadius(14).backgroundColor(PRIMARY_LIGHT)
     .border({ width: 1, color: PRIMARY_BORDER });
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
             .border({ width: 1, color: BORDER_DEFAULT });

            Column({ space: 10 }) {
              Text('在线编辑').fontSize(16).fontWeight(FontWeight.Bold).fontColor('#111827').width('100%');
              TextArea({ text: this.editedResume, placeholder: '纯文本简历，方便复制修改' })
                .fontSize(14).fontColor('#111827').width('100%').height(140).borderRadius(12)
                .backgroundColor(PRIMARY_LIGHT).padding(12).border({ width: 1, color: BORDER_DEFAULT })
                .onChange((v: string) => { this.editedResume = v; this.exportStatus = ''; });
            }.width('100%').padding(16).borderRadius(16).backgroundColor('#FFFFFF')
             .border({ width: 1, color: BORDER_DEFAULT });

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
                .height(42).fontSize(14).fontColor(PRIMARY_DARK).backgroundColor(PRIMARY_LIGHT)
                .layoutWeight(1).borderRadius(12)
                .enabled(!this.isScoring).onClick(() => { this.refreshScore(); });
              Button(this.isExporting ? '生成中...' : '导出 PDF')
                .height(42).fontSize(14).fontColor('#FFFFFF').backgroundColor(PRIMARY)
                .layoutWeight(1).borderRadius(12)
                .enabled(!this.isExporting).onClick(() => { this.exportPdf(); });
            }.width('100%');

            if (this.lastPdfPath.length > 0) {
              Row({ space: 10 }) {
                Button(this.isSavingPdf ? '保存中...' : '保存到本地')
                  .height(42).fontSize(14).fontColor(PRIMARY).backgroundColor(PRIMARY_LIGHT)
                  .layoutWeight(1).borderRadius(12)
                  .enabled(!this.isSavingPdf).onClick(() => { this.savePdfToPublicDir(); });
                Button(this.serverRunning ? '停止服务' : '发送到PC')
                  .height(42).fontSize(14)
                  .fontColor(this.serverRunning ? '#DC2626' : PRIMARY)
                  .backgroundColor(this.serverRunning ? '#FEE2E2' : PRIMARY_LIGHT)
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
          Button('\u2190 上一步').fontSize(15).fontColor('#6B7280').layoutWeight(1).height(48)
            .borderRadius(12).backgroundColor('#F3F4F6')
            .onClick(() => { router.back(); });
          Button('返回首页').fontSize(15).fontWeight(FontWeight.Medium).fontColor('#FFFFFF')
            .layoutWeight(1).height(48).borderRadius(12).backgroundColor(PRIMARY)
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
    .width('100%').height('100%').backgroundColor(BG_PAGE);
  }
}
