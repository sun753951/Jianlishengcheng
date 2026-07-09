from fastapi import FastAPI
from fastapi.responses import Response

from server.models import GenerateResumeResponse, ResumeFormData, ResumeTextRequest, ScoreResumeResponse
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
def export_resume_pdf_api(request: ResumeTextRequest) -> Response:
    pdf_bytes = build_resume_pdf(request.resumeText)
    safe_file_name = "resume.pdf"
    return Response(
        content=pdf_bytes,
        media_type="application/pdf",
        headers={"Content-Disposition": f'attachment; filename="{safe_file_name}"'},
    )
