import http from '@ohos.net.http';
import { ResumeFormData, ResumePreviewData, ResumeScoreResult, ResumeTemplateType } from '../model/ResumeModels';

const API_BASE_URL: string = 'http://127.0.0.1:8000';

export interface GenerateResumeRequest {
  name: string;
  photoUri: string;
  phone: string;
  email: string;
  education: string;
  targetPosition: string;
  skills: string;
  workExperience: string;
  projectExperience: string;
  selfEvaluation: string;
  templateType: string;
}

export interface ScoreResumeRequest extends GenerateResumeRequest {
  resumeText: string;
}

export interface GenerateResumeApiResponse {
  resumeText: string;
  previewData: ResumePreviewData;
  modelName: string;
  usedFallback: boolean;
  generationTimeMs: number;
}

interface ScoreResumeApiResponse {
  totalScore: number;
  structureScore: number;
  contentScore: number;
  jobMatchScore: number;
  level: string;
  suggestions: string[];
}

export interface PdfExportResult {
  fileName: string;
  byteLength: number;
}

export function getTemplateApiValue(templateType: ResumeTemplateType): string {
  if (templateType === ResumeTemplateType.STANDARD) {
    return 'standard';
  }
  if (templateType === ResumeTemplateType.CAMPUS) {
    return 'campus';
  }
  if (templateType === ResumeTemplateType.EXECUTIVE) {
    return 'executive';
  }
  if (templateType === ResumeTemplateType.MINIMAL) {
    return 'minimal';
  }
  if (templateType === ResumeTemplateType.BLACK_GOLD) {
    return 'blackgold';
  }
  return 'technical';
}

export function createGenerateResumeRequest(formData: ResumeFormData, templateType: ResumeTemplateType): GenerateResumeRequest {
  return {
    name: formData.name,
    photoUri: formData.photoUri,
    phone: formData.phone,
    email: formData.email,
    education: formData.education,
    targetPosition: formData.targetPosition,
    skills: formData.skills,
    workExperience: formData.workExperience,
    projectExperience: formData.projectExperience,
    selfEvaluation: formData.selfEvaluation,
    templateType: getTemplateApiValue(templateType)
  };
}

export function createScoreResumeRequest(formData: ResumeFormData, templateType: ResumeTemplateType, resumeText: string): ScoreResumeRequest {
  const request: GenerateResumeRequest = createGenerateResumeRequest(formData, templateType);
  return {
    name: request.name,
    photoUri: request.photoUri,
    phone: request.phone,
    email: request.email,
    education: request.education,
    targetPosition: request.targetPosition,
    skills: request.skills,
    workExperience: request.workExperience,
    projectExperience: request.projectExperience,
    selfEvaluation: request.selfEvaluation,
    templateType: request.templateType,
    resumeText: resumeText
  };
}

function getResponseText(response: http.HttpResponse): string {
  if (typeof response.result === 'string') {
    return response.result;
  }
  return '';
}

async function postJson(path: string, body: object): Promise<http.HttpResponse> {
  const request = http.createHttp();
  try {
    try {
      return await request.request(`${API_BASE_URL}${path}`, {
        method: http.RequestMethod.POST,
        header: {
          'Content-Type': 'application/json'
        },
        extraData: JSON.stringify(body),
        connectTimeout: 5000,
        readTimeout: 10000
      });
    } catch (error) {
      throw new Error('resume api request failed');
    }
  } finally {
    request.destroy();
  }
}

export async function requestGenerateResume(formData: ResumeFormData, templateType: ResumeTemplateType): Promise<GenerateResumeApiResponse> {
  const response: http.HttpResponse = await postJson('/api/resume/generate', createGenerateResumeRequest(formData, templateType));
  if (response.responseCode !== 200) {
    throw new Error('resume generate api failed');
  }
  return JSON.parse(getResponseText(response)) as GenerateResumeApiResponse;
}

export async function requestScoreResume(formData: ResumeFormData, templateType: ResumeTemplateType, resumeText: string): Promise<ResumeScoreResult> {
  const response: http.HttpResponse = await postJson('/api/resume/score', createScoreResumeRequest(formData, templateType, resumeText));
  if (response.responseCode !== 200) {
    throw new Error('resume score api failed');
  }
  const scoreResponse: ScoreResumeApiResponse = JSON.parse(getResponseText(response)) as ScoreResumeApiResponse;
  return {
    score: scoreResponse.totalScore,
    level: scoreResponse.level,
    suggestions: scoreResponse.suggestions
  };
}

export async function requestExportPdf(formData: ResumeFormData, templateType: ResumeTemplateType, resumeText: string): Promise<PdfExportResult> {
  const response: http.HttpResponse = await postJson('/api/resume/export/pdf', createScoreResumeRequest(formData, templateType, resumeText));
  if (response.responseCode !== 200) {
    throw new Error('resume pdf export api failed');
  }
  const result: string | ArrayBuffer = response.result as string | ArrayBuffer;
  let byteLength: number = 0;
  if (typeof result === 'string') {
    byteLength = result.length;
  } else {
    byteLength = result.byteLength;
  }
  return {
    fileName: 'resume.pdf',
    byteLength: byteLength
  };
}
