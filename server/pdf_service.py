import io
from typing import Iterable

from reportlab.lib.pagesizes import A4
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.cidfonts import UnicodeCIDFont
from reportlab.pdfgen import canvas


def _chunks(line: str, size: int) -> Iterable[str]:
    if not line:
        yield ""
        return
    for index in range(0, len(line), size):
        yield line[index:index + size]


def build_resume_pdf(resume_text: str) -> bytes:
    pdfmetrics.registerFont(UnicodeCIDFont("STSong-Light"))
    buffer = io.BytesIO()
    pdf = canvas.Canvas(buffer, pagesize=A4)
    width, height = A4
    margin_x = 54
    y = height - 54
    line_height = 18

    pdf.setTitle("resume")
    pdf.setFont("STSong-Light", 16)
    pdf.drawString(margin_x, y, "智能简历生成系统 - 简历")
    y -= 30
    pdf.setFont("STSong-Light", 11)

    for raw_line in resume_text.splitlines():
        for line in _chunks(raw_line, 42):
            if y < 54:
                pdf.showPage()
                pdf.setFont("STSong-Light", 11)
                y = height - 54
            pdf.drawString(margin_x, y, line)
            y -= line_height

    pdf.showPage()
    pdf.save()
    return buffer.getvalue()
