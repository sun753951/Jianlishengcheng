from fastapi import FastAPI
from fastapi.responses import Response

from server.models import GenerateResumeResponse, PdfExportRequest, ResumeFormData, ResumeTextRequest, ScoreResumeResponse
from server.pdf_service import build_resume_pdf
from server.resume_service import generate_resume, score_resume


app = FastAPI(
    title="Intelligent Resume Generation API",
    version="1.0.0",
)


@app.get("/api/health")
def health() -> dict:
    return {"status": "ok"}


@app.post("/api/resume/generate", response_model=GenerateResumeResponse)
def generate_resume_api(form_data: ResumeFormData) -> GenerateResumeResponse:
    return generate_resume(form_data)


@app.post("/api/resume/score", response_model=ScoreResumeResponse)
def score_resume_api(form_data: ResumeFormData) -> ScoreResumeResponse:
    return score_resume(form_data)


@app.post("/api/resume/export/pdf")
def export_resume_pdf_api(request: PdfExportRequest) -> Response:
    pdf_bytes = build_resume_pdf(
        name=request.name,
        phone=request.phone,
        email=request.email,
        target_position=request.targetPosition,
        education=request.education,
        skills=request.skills,
        work_experience=request.workExperience,
        project_experience=request.projectExperience,
        self_evaluation=request.selfEvaluation,
        template_type=request.templateType,
    )
    safe_file_name = "resume.pdf"
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": f'attachment; filename="{safe_file_name}"'},
    )
