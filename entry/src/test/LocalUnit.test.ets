import { describe, it, expect } from '@ohos/hypium';
import { ButtonFeedbackState, getButtonFeedbackScale } from '../main/ets/model/ButtonFeedbackModels';
import { DEMO_PHOTO_URI, ResumeFormData, ResumePreviewData, ResumeTemplateType } from '../main/ets/model/ResumeModels';
import { createGenerateResumeRequest, createScoreResumeRequest, getTemplateApiValue } from '../main/ets/service/ResumeApiService';
import { generateResumePreview, generateResumeText, scoreResume } from '../main/ets/service/ResumeService';

function createCompleteForm(): ResumeFormData {
  return {
    name: '李明',
    photoUri: DEMO_PHOTO_URI,
    phone: '13800000000',
    email: 'liming@example.com',
    education: '华南理工大学 软件工程 本科',
    targetPosition: 'HarmonyOS 应用开发工程师',
    skills: 'ArkTS, ArkUI, TypeScript, Python, MySQL',
    workExperience: '在校期间参与移动应用开发实训，负责页面开发与接口联调。',
    projectExperience: '智能简历生成系统：负责表单设计、简历生成、评分建议与导出流程。',
    selfEvaluation: '学习能力强，关注代码规范，具备良好的团队协作意识。'
  };
}

export default function localUnitTest(): void {
  describe('resumeService', () => {
    it('generates resume text with candidate information and target position', 0, () => {
      const resumeText: string = generateResumeText(createCompleteForm(), ResumeTemplateType.TECHNICAL);

      expect(resumeText).assertContain('李明');
      expect(resumeText).assertContain('HarmonyOS 应用开发工程师');
      expect(resumeText).assertContain('ArkTS');
      expect(resumeText).assertContain('项目经历');
    });

    it('scores complete resume higher than incomplete resume', 0, () => {
      const completeScore: number = scoreResume(createCompleteForm()).score;
      const incompleteForm: ResumeFormData = createCompleteForm();
      incompleteForm.projectExperience = '';
      incompleteForm.email = '';
      const incompleteResult = scoreResume(incompleteForm);

      expect(completeScore > incompleteResult.score).assertTrue();
      expect(incompleteResult.suggestions.length > 0).assertTrue();
    });

    it('builds structured resume preview data for visual templates', 0, () => {
      const previewData: ResumePreviewData = generateResumePreview(createCompleteForm(), ResumeTemplateType.TECHNICAL);

      expect(previewData.name).assertEqual('李明');
      expect(previewData.photoUri).assertEqual(DEMO_PHOTO_URI);
      expect(previewData.targetPosition).assertContain('HarmonyOS');
      expect(previewData.skillTags.length > 1).assertTrue();
      expect(previewData.sidebarSections.length > 0).assertTrue();
      expect(previewData.mainSections.length > 1).assertTrue();
    });
  });

  describe('buttonFeedback', () => {
    it('returns distinct scales for normal hover and pressed states', 0, () => {
      const normalScale: number = getButtonFeedbackScale(ButtonFeedbackState.NORMAL);
      const hoverScale: number = getButtonFeedbackScale(ButtonFeedbackState.HOVERED);
      const pressedScale: number = getButtonFeedbackScale(ButtonFeedbackState.PRESSED);

      expect(hoverScale > normalScale).assertTrue();
      expect(pressedScale < normalScale).assertTrue();
      expect(normalScale).assertEqual(1);
    });
  });

  describe('resumeApiService', () => {
    it('maps template enum to backend template value', 0, () => {
      expect(getTemplateApiValue(ResumeTemplateType.STANDARD)).assertEqual('standard');
      expect(getTemplateApiValue(ResumeTemplateType.TECHNICAL)).assertEqual('technical');
      expect(getTemplateApiValue(ResumeTemplateType.CAMPUS)).assertEqual('campus');
      expect(getTemplateApiValue(ResumeTemplateType.EXECUTIVE)).assertEqual('executive');
      expect(getTemplateApiValue(ResumeTemplateType.MINIMAL)).assertEqual('minimal');
      expect(getTemplateApiValue(ResumeTemplateType.BLACK_GOLD)).assertEqual('blackgold');
    });

    it('builds backend request from local form data', 0, () => {
      const request = createGenerateResumeRequest(createCompleteForm(), ResumeTemplateType.TECHNICAL);

      expect(request.name).assertEqual('李明');
      expect(request.templateType).assertEqual('technical');
      expect(request.targetPosition).assertContain('HarmonyOS');
    });

    it('builds score request with edited resume text when provided', 0, () => {
      const request = createScoreResumeRequest(createCompleteForm(), ResumeTemplateType.CAMPUS, '编辑后的简历正文');

      expect(request.templateType).assertEqual('campus');
      expect(request.resumeText).assertEqual('编辑后的简历正文');
    });
  });
}
