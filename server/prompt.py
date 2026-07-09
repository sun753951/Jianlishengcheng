from server.models import ResumeFormData


PROMPT_TEMPLATE = """你是一名简历生成助手。请只基于候选人提供的真实信息生成中文简历，不得编造学历、公司、证书、工作年限、项目成果或联系方式。

目标岗位：{target_position}
模板风格：{template_type}
候选人信息：
- 姓名：{name}
- 教育经历：{education}
- 技能关键词：{skills}
- 工作/实习经历：{work_experience}
- 项目经历：{project_experience}
- 自我评价：{self_evaluation}

输出要求：
1. 使用结构化中文简历格式。
2. 必须包含个人摘要、教育经历、核心技能、工作/实习经历、项目经历、自我评价。
3. 内容围绕目标岗位表达，但不添加用户未提供的事实。
4. 语言简洁、正式、语法正确。
"""


def build_generation_prompt(form_data: ResumeFormData) -> str:
    return PROMPT_TEMPLATE.format(
        target_position=form_data.targetPosition.strip(),
        template_type=form_data.templateType.value,
        name=form_data.name.strip(),
        education=form_data.education.strip(),
        skills=form_data.skills.strip() or "未提供",
        work_experience=form_data.workExperience.strip() or "未提供",
        project_experience=form_data.projectExperience.strip(),
        self_evaluation=form_data.selfEvaluation.strip() or "未提供",
    )
