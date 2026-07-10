import io
from typing import Iterable

from reportlab.lib.pagesizes import A4
from reportlab.lib.colors import HexColor, white, black
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
from reportlab.pdfgen import canvas


TEMPLATE_COLORS = {
    "standard":   ("#0F766E", "#CCFBF1"),
    "technical":  ("#1D4ED8", "#DBEAFE"),
    "campus":     ("#7C3AED", "#EDE9FE"),
    "executive":  ("#B45309", "#FEF3C7"),
    "minimal":    ("#374151", "#F3F4F6"),
    "blackgold":  ("#D4AF37", "#1F2937"),
}
DEFAULT_COLOR = ("#1D4ED8", "#DBEAFE")


def _chunks(line: str, size: int) -> Iterable[str]:
    if not line:
        yield ""
        return
    for index in range(0, len(line), size):
        yield line[index:index + size]


def _draw_section_header(pdf: canvas.Canvas, x: float, y: float, text: str, accent_hex: str, max_width: float):
    accent = HexColor(accent_hex)
    pdf.setFillColor(accent)
    pdf.setFont("STSong-Light", 14)
    pdf.drawString(x, y, text)
    pdf.setStrokeColor(accent)
    pdf.setLineWidth(1.5)
    line_y = y - 4
    pdf.line(x, line_y, x + max_width, line_y)
    pdf.setFillColor(black)


def _draw_multiline(pdf: canvas.Canvas, x: float, y: float, text: str, width: int, line_height: int, pdf_width: float):
    current_y = y
    font_size = 11
    pdf.setFont("STSong-Light", font_size)
    for raw_line in text.splitlines():
        for line in _chunks(raw_line, width):
            if current_y < 54:
                pdf.showPage()
                pdf.setFont("STSong-Light", font_size)
                current_y = A4[1] - 54
            pdf.drawString(x, current_y, line)
            current_y -= line_height
    return current_y


def build_resume_pdf(name: str, phone: str, email: str, target_position: str,
                     education: str, skills: str, work_experience: str,
                     project_experience: str, self_evaluation: str,
                     template_type: str = "standard") -> bytes:
    pdfmetrics.registerFont(UnicodeCIDFont("STSong-Light"))
    buffer = io.BytesIO()
    pdf = canvas.Canvas(buffer, pagesize=A4)
    page_w, page_h = A4
    mx = 54
    content_w = page_w - mx * 2
    y = page_h - 54
    lh = 18

    accent_hex, bg_hex = TEMPLATE_COLORS.get(template_type, DEFAULT_COLOR)
    accent = HexColor(accent_hex)

    pdf.setTitle(f"{name} - 简历")

    # ── Header section ──
    pdf.setFont("STSong-Light", 24)
    pdf.setFillColor(accent)
    pdf.drawCentredString(page_w / 2, y, name)
    y -= 28

    pdf.setFont("STSong-Light", 13)
    pdf.setFillColor(HexColor("#555555"))
    if target_position.strip():
        pdf.drawCentredString(page_w / 2, y, target_position)
    y -= 20

    contact = f"{phone}  |  {email}"
    pdf.setFont("STSong-Light", 10)
    pdf.setFillColor(HexColor("#888888"))
    pdf.drawCentredString(page_w / 2, y, contact)
    y -= 28

    # ── Accent line ──
    pdf.setStrokeColor(accent)
    pdf.setLineWidth(2)
    pdf.line(mx, y, mx + content_w, y)
    y -= 22
    pdf.setFillColor(black)

    # ── Sections ──
    sections = []
    if education.strip():
        sections.append(("教育背景", education))
    if skills.strip():
        sections.append(("专业技能", skills))
    if work_experience.strip():
        sections.append(("工作经历", work_experience))
    if project_experience.strip():
        sections.append(("项目经验", project_experience))
    if self_evaluation.strip():
        sections.append(("自我评价", self_evaluation))

    for title, content in sections:
        if y < 100:
            pdf.showPage()
            y = page_h - 54
        _draw_section_header(pdf, mx, y, title, accent_hex, content_w)
        y -= 24
        y = _draw_multiline(pdf, mx + 6, y, content, 42, lh, page_w)
        y -= 14

    pdf.showPage()
    pdf.save()
    return buffer.getvalue()
