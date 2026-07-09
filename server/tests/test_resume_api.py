import io

from fastapi.testclient import TestClient

from server.app import app


client = TestClient(app)


def complete_payload() -> dict:
    return {
        "name": "李明",
        "photoUri": "",
        "phone": "13800000000",
        "email": "liming@example.com",
        "education": "华南理工大学 软件工程 本科",
        "targetPosition": "HarmonyOS 应用开发工程师",
        "skills": "ArkTS, ArkUI, Python, FastAPI",
        "workExperience": "参与移动应用开发实训，负责页面开发和接口联调。",
        "projectExperience": "智能简历生成系统：负责表单、模板、评分建议和 PDF 导出。",
        "selfEvaluation": "学习能力强，重视代码规范和隐私保护。",
        "templateType": "technical",
    }


def test_generate_resume_returns_text_preview_and_timing() -> None:
    response = client.post("/api/resume/generate", json=complete_payload())

    assert response.status_code == 200
    body = response.json()
    assert body["resumeText"]
    assert "HarmonyOS 应用开发工程师" in body["resumeText"]
    assert "智能简历生成系统" in body["resumeText"]
    assert body["previewData"]["name"] == "李明"
    assert len(body["previewData"]["mainSections"]) >= 3
    assert body["generationTimeMs"] >= 0
    assert body["modelName"]


def test_generate_resume_rejects_missing_required_fields() -> None:
    payload = complete_payload()
    payload["name"] = ""

    response = client.post("/api/resume/generate", json=payload)

    assert response.status_code == 422


def test_score_resume_returns_breakdown_and_suggestions() -> None:
    response = client.post("/api/resume/score", json=complete_payload())

    assert response.status_code == 200
    body = response.json()
    assert body["totalScore"] >= 80
    assert body["structureScore"] > 0
    assert body["contentScore"] > 0
    assert body["jobMatchScore"] > 0
    assert body["suggestions"]


def test_generate_resume_accepts_premium_template_types() -> None:
    expected_titles = {
        "executive": "高级商务简历",
        "minimal": "极简灰白简历",
        "blackgold": "黑金双栏简历",
    }
    for template_type, expected_title in expected_titles.items():
        payload = complete_payload()
        payload["templateType"] = template_type

        response = client.post("/api/resume/generate", json=payload)

        assert response.status_code == 200
        body = response.json()
        assert expected_title in body["resumeText"]
        assert body["previewData"]["targetPosition"] == "HarmonyOS 应用开发工程师"


def test_export_pdf_returns_valid_pdf_bytes() -> None:
    payload = complete_payload()
    payload["resumeText"] = "技术岗位定制简历\n\n姓名：李明\n求职岗位：HarmonyOS 应用开发工程师"

    response = client.post("/api/resume/export/pdf", json=payload)

    assert response.status_code == 200
    assert response.headers["content-type"] == "application/pdf"
    assert response.content.startswith(b"%PDF")
    assert len(io.BytesIO(response.content).getvalue()) > 1000
