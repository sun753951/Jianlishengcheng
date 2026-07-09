import os
import time
from typing import List, Optional, Tuple

from server.models import (
    GenerateResumeResponse,
    ResumeFormData,
    ResumePreviewData,
    ResumePreviewSection,
    ScoreResumeResponse,
    TemplateType,
)
from server.prompt import build_generation_prompt


DEFAULT_MODEL_NAME = "uer/gpt2-chinese-cluecorpussmall"


def _normalize(value: str) -> str:
    return value.strip()


def _fallback(value: str, fallback: str) -> str:
    normalized = _normalize(value)
    if normalized:
        return normalized
    return fallback


def _has_content(value: str) -> bool:
    return bool(_normalize(value))


def _split_skill_tags(skills: str) -> List[str]:
    normalized = _normalize(skills)
    if not normalized:
        return ["待补充技能"]
    return [
        item.strip()
        for item in normalized.replace("，", ",").replace("、", ",").split(",")
        if item.strip()
    ][:8]


def _section(title: str, content: str) -> ResumePreviewSection:
    return ResumePreviewSection(title=title, content=content)


def build_summary(form_data: ResumeFormData) -> str:
    target_position = _fallback(form_data.targetPosition, "目标岗位")
    if form_data.templateType == TemplateType.technical:
        return f"围绕{target_position}岗位要求，突出技术能力、项目落地经验和工程规范意识。"
    if form_data.templateType == TemplateType.campus:
        return f"面向{target_position}岗位，突出教育背景、课程实践、学习能力和成长潜力。"
    if form_data.templateType == TemplateType.executive:
        return f"面向{target_position}岗位，突出战略视角、跨团队协作、项目推进能力和结果导向。"
    if form_data.templateType == TemplateType.minimal:
        return f"围绕{target_position}岗位，使用克制清晰的表达呈现教育背景、技能优势和核心经历。"
    if form_data.templateType == TemplateType.blackgold:
        return f"面向{target_position}岗位，突出候选人的核心价值、关键技能和高可信度项目经验。"
    return f"面向{target_position}岗位，展示个人基础信息、核心技能、实践经历和职业优势。"


def build_preview_data(form_data: ResumeFormData) -> ResumePreviewData:
    summary = build_summary(form_data)
    education = _fallback(form_data.education, "未填写教育经历")
    work_experience = _fallback(form_data.workExperience, "暂无工作或实习经历，可补充真实经历。")
    project_experience = _fallback(form_data.projectExperience, "暂无项目经历，可补充课程设计或实践项目。")
    self_evaluation = _fallback(form_data.selfEvaluation, "暂无自我评价，可补充个人优势和职业态度。")

    sidebar_sections = [
        _section("教育背景", education),
        _section("个人优势", self_evaluation),
    ]
    main_sections = [
        _section("个人简介", summary),
        _section("项目经历", project_experience),
        _section("工作/实习经历", work_experience),
    ]

    if form_data.templateType == TemplateType.campus:
        sidebar_sections = [
            _section("教育背景", education),
            _section("校园/实训亮点", work_experience),
        ]
        main_sections = [
            _section("求职摘要", summary),
            _section("项目实践", project_experience),
            _section("自我评价", self_evaluation),
        ]

    if form_data.templateType == TemplateType.standard:
        sidebar_sections = [
            _section("联系方式", f"{_fallback(form_data.phone, '未填写电话')}\n{_fallback(form_data.email, '未填写邮箱')}"),
            _section("教育背景", education),
        ]
        main_sections = [
            _section("个人简介", summary),
            _section("工作/实习经历", work_experience),
            _section("项目经历", project_experience),
            _section("自我评价", self_evaluation),
        ]

    if form_data.templateType == TemplateType.executive:
        sidebar_sections = [
            _section("核心信息", f"{_fallback(form_data.phone, '未填写电话')}\n{_fallback(form_data.email, '未填写邮箱')}\n{education}"),
            _section("能力标签", " / ".join(_split_skill_tags(form_data.skills))),
        ]
        main_sections = [
            _section("职业摘要", summary),
            _section("关键项目", project_experience),
            _section("经历亮点", work_experience),
            _section("个人优势", self_evaluation),
        ]

    if form_data.templateType == TemplateType.minimal:
        sidebar_sections = [
            _section("联系方式", f"{_fallback(form_data.phone, '未填写电话')}\n{_fallback(form_data.email, '未填写邮箱')}"),
            _section("教育", education),
        ]
        main_sections = [
            _section("摘要", summary),
            _section("技能", _fallback(form_data.skills, "未填写技能关键词")),
            _section("项目", project_experience),
            _section("经历", work_experience),
        ]

    if form_data.templateType == TemplateType.blackgold:
        sidebar_sections = [
            _section("PROFILE", summary),
            _section("CONTACT", f"{_fallback(form_data.phone, '未填写电话')}\n{_fallback(form_data.email, '未填写邮箱')}"),
            _section("EDUCATION", education),
        ]
        main_sections = [
            _section("SIGNATURE PROJECT", project_experience),
            _section("EXPERIENCE", work_experience),
            _section("STRENGTHS", self_evaluation),
        ]

    return ResumePreviewData(
        name=_fallback(form_data.name, "未填写姓名"),
        photoUri=_normalize(form_data.photoUri),
        targetPosition=_fallback(form_data.targetPosition, "未填写求职岗位"),
        phone=_fallback(form_data.phone, "未填写电话"),
        email=_fallback(form_data.email, "未填写邮箱"),
        summary=summary,
        skillTags=_split_skill_tags(form_data.skills),
        sidebarSections=sidebar_sections,
        mainSections=main_sections,
    )


def build_rule_based_resume(form_data: ResumeFormData) -> str:
    title = {
        TemplateType.technical: "技术岗位定制简历",
        TemplateType.campus: "校园招聘简历",
        TemplateType.standard: "标准求职简历",
        TemplateType.executive: "高级商务简历",
        TemplateType.minimal: "极简灰白简历",
        TemplateType.blackgold: "黑金双栏简历",
    }[form_data.templateType]

    return f"""{title}

姓名：{_fallback(form_data.name, '未填写姓名')}
求职岗位：{_fallback(form_data.targetPosition, '未填写求职岗位')}
联系方式：{_fallback(form_data.phone, '未填写联系电话')} / {_fallback(form_data.email, '未填写邮箱')}

个人摘要：
{build_summary(form_data)}

教育经历：
{_fallback(form_data.education, '未填写教育经历')}

核心技能：
{_fallback(form_data.skills, '未填写技能关键词')}

工作/实习经历：
{_fallback(form_data.workExperience, '暂无工作或实习经历，可补充真实经历。')}

项目经历：
{_fallback(form_data.projectExperience, '暂无项目经历，可补充课程设计或实践项目。')}

自我评价：
{_fallback(form_data.selfEvaluation, '暂无自我评价，可补充个人优势和职业态度。')}"""


class ResumeGenerator:
    def __init__(self) -> None:
        self.model_name = os.getenv("RESUME_MODEL_PATH", os.getenv("RESUME_MODEL_NAME", DEFAULT_MODEL_NAME))
        self._pipeline = None
        self._load_attempted = False

    def _load_pipeline(self) -> Optional[object]:
        if self._load_attempted:
            return self._pipeline
        self._load_attempted = True
        if os.getenv("RESUME_DISABLE_TRANSFORMERS", "1") == "1":
            return None
        try:
            from transformers import pipeline

            self._pipeline = pipeline("text-generation", model=self.model_name)
        except Exception:
            self._pipeline = None
        return self._pipeline

    def generate(self, form_data: ResumeFormData) -> Tuple[str, bool]:
        prompt = build_generation_prompt(form_data)
        generator = self._load_pipeline()
        if generator is None:
            return build_rule_based_resume(form_data), True

        try:
            results = generator(prompt, max_new_tokens=260, do_sample=False)
            generated = str(results[0].get("generated_text", "")).replace(prompt, "").strip()
            if len(generated) < 40:
                return build_rule_based_resume(form_data), True
            return generated, False
        except Exception:
            return build_rule_based_resume(form_data), True


generator = ResumeGenerator()


def generate_resume(form_data: ResumeFormData) -> GenerateResumeResponse:
    start = time.perf_counter()
    resume_text, used_fallback = generator.generate(form_data)
    elapsed_ms = int((time.perf_counter() - start) * 1000)
    return GenerateResumeResponse(
        resumeText=resume_text,
        previewData=build_preview_data(form_data),
        modelName=generator.model_name if not used_fallback else f"{generator.model_name} (fallback)",
        usedFallback=used_fallback,
        generationTimeMs=elapsed_ms,
    )


def score_resume(form_data: ResumeFormData) -> ScoreResumeResponse:
    structure_score = 35
    if _has_content(form_data.name):
        structure_score += 5
    if _has_content(form_data.phone) or _has_content(form_data.email):
        structure_score += 5
    if _has_content(form_data.education):
        structure_score += 5
    structure_score = min(structure_score, 50)

    content_score = 15
    if _has_content(form_data.skills):
        content_score += 10
    if _has_content(form_data.workExperience):
        content_score += 8
    if _has_content(form_data.projectExperience):
        content_score += 12
    content_score = min(content_score, 35)

    job_match_score = 5
    target = _normalize(form_data.targetPosition)
    combined = " ".join([form_data.skills, form_data.workExperience, form_data.projectExperience])
    if target:
        job_match_score += 5
    for keyword in _split_skill_tags(form_data.skills):
        if keyword != "待补充技能" and keyword in combined:
            job_match_score += 1
    job_match_score = min(job_match_score, 15)

    total_score = structure_score + content_score + job_match_score
    suggestions: List[str] = []
    if not _has_content(form_data.phone) and not _has_content(form_data.email):
        suggestions.append("至少填写一种联系方式，避免招聘方无法联系。")
    if not _has_content(form_data.skills):
        suggestions.append("补充 3-6 个岗位相关技能关键词。")
    if not _has_content(form_data.workExperience):
        suggestions.append("如没有实习经历，可填写课程实践、社团协作或实训经历。")
    if not _has_content(form_data.projectExperience):
        suggestions.append("补充真实项目经历，建议包含项目名称、职责和结果。")
    if not suggestions:
        suggestions.append("信息完整度较高，可以继续量化项目结果并强化岗位关键词。")
        suggestions.append("检查所有描述是否真实准确，避免夸大学历、证书或工作年限。")

    if total_score >= 90:
        level = "优秀"
    elif total_score >= 75:
        level = "良好"
    elif total_score >= 60:
        level = "待完善"
    else:
        level = "信息不足"

    return ScoreResumeResponse(
        totalScore=total_score,
        structureScore=structure_score,
        contentScore=content_score,
        jobMatchScore=job_match_score,
        level=level,
        suggestions=suggestions,
    )
