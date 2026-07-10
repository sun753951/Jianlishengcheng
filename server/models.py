from enum import Enum
from typing import List

from pydantic import BaseModel, Field


class TemplateType(str, Enum):
    standard = "standard"
    technical = "technical"
    campus = "campus"
    executive = "executive"
    minimal = "minimal"
    blackgold = "blackgold"


class ResumeFormData(BaseModel):
    name: str = Field(min_length=1)
    photoUri: str = ""
    phone: str = ""
    email: str = ""
    education: str = Field(min_length=1)
    targetPosition: str = Field(min_length=1)
    skills: str = ""
    workExperience: str = ""
    projectExperience: str = Field(min_length=1)
    selfEvaluation: str = ""
    templateType: TemplateType = TemplateType.technical


class ResumeTextRequest(BaseModel):
    resumeText: str = Field(min_length=1)


class PdfExportRequest(BaseModel):
    name: str = ""
    phone: str = ""
    email: str = ""
    targetPosition: str = ""
    education: str = ""
    skills: str = ""
    workExperience: str = ""
    projectExperience: str = ""
    selfEvaluation: str = ""
    templateType: str = "standard"


class ResumePreviewSection(BaseModel):
    title: str
    content: str


class ResumePreviewData(BaseModel):
    name: str
    photoUri: str
    targetPosition: str
    phone: str
    email: str
    summary: str
    skillTags: List[str]
    sidebarSections: List[ResumePreviewSection]
    mainSections: List[ResumePreviewSection]


class GenerateResumeResponse(BaseModel):
    resumeText: str
    previewData: ResumePreviewData
    modelName: str
    usedFallback: bool
    generationTimeMs: int


class ScoreResumeResponse(BaseModel):
    totalScore: int
    structureScore: int
    contentScore: int
    jobMatchScore: int
    level: str
    suggestions: List[str]
