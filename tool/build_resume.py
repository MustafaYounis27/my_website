"""Builds the resume PDF from assets/data/cv.json, so the PDF and the site
never drift apart.

    python3 -m venv .venv && .venv/bin/pip install reportlab==4.2.5
    .venv/bin/python tool/build_resume.py

Writes assets/pdf/Mustafa_Younis_Resume.pdf and its served copy in web/.
"""

import json
import re
import shutil
from pathlib import Path
from xml.sax.saxutils import escape

from reportlab.lib.colors import HexColor
from reportlab.lib.enums import TA_LEFT, TA_RIGHT
from reportlab.lib.pagesizes import LETTER
from reportlab.lib.styles import ParagraphStyle
from reportlab.lib.units import inch
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.platypus import (
    HRFlowable,
    KeepTogether,
    ListFlowable,
    ListItem,
    Paragraph,
    SimpleDocTemplate,
    Spacer,
    Table,
    TableStyle,
)

ROOT = Path(__file__).resolve().parent.parent
SITE = "https://mustafa-younis-portfolio.web.app"
OUTPUTS = [ROOT / "assets/pdf/Mustafa_Younis_Resume.pdf", ROOT / "web/Mustafa_Younis_Resume.pdf"]

INK = HexColor("#14142B")
MUTED = HexColor("#5A5A75")
ACCENT = HexColor("#4F46E5")
RULE = HexColor("#D9D8EA")

# The site's own faces, bundled in assets/fonts.
for name, file in [
    ("Inter", "Inter-400.ttf"),
    ("Inter-Medium", "Inter-500.ttf"),
    ("Inter-SemiBold", "Inter-600.ttf"),
    ("Inter-Bold", "Inter-700.ttf"),
    ("Poppins-Bold", "Poppins-700.ttf"),
]:
    pdfmetrics.registerFont(TTFont(name, str(ROOT / "assets/fonts" / file)))
pdfmetrics.registerFontFamily("Inter", normal="Inter", bold="Inter-Bold", italic="Inter", boldItalic="Inter-Bold")

STYLES = {
    "name": ParagraphStyle("name", fontName="Poppins-Bold", fontSize=24, leading=28, textColor=INK),
    "title": ParagraphStyle("title", fontName="Inter-SemiBold", fontSize=12, leading=16, textColor=ACCENT),
    "contact": ParagraphStyle("contact", fontName="Inter", fontSize=8.8, leading=13, textColor=MUTED),
    "section": ParagraphStyle(
        "section", fontName="Inter-Bold", fontSize=9.5, leading=12, textColor=ACCENT, spaceBefore=12, spaceAfter=3
    ),
    "body": ParagraphStyle("body", fontName="Inter", fontSize=9.3, leading=13.4, textColor=INK, alignment=TA_LEFT),
    "role": ParagraphStyle("role", fontName="Inter-Bold", fontSize=10.3, leading=13.5, textColor=INK),
    "meta": ParagraphStyle("meta", fontName="Inter", fontSize=8.6, leading=12, textColor=MUTED),
    "date": ParagraphStyle("date", fontName="Inter-Medium", fontSize=8.6, leading=12, textColor=MUTED, alignment=TA_RIGHT),
    "bullet": ParagraphStyle("bullet", fontName="Inter", fontSize=9.1, leading=12.8, textColor=INK),
}


def text(s: str) -> str:
    """Escapes for Paragraph markup and swaps glyphs the bundled Latin subset lacks."""
    s = re.sub(r"(\d(?:\.\d)?)★", r"\1-star", s)
    return escape(s)


def link(url: str, label: str) -> str:
    return f'<a href="{escape(url)}" color="#4F46E5">{escape(label)}</a>'


def store_label(url: str) -> str:
    for host, label in [
        ("apple.com", "App Store"),
        ("play.google.com", "Google Play"),
        ("appgallery.huawei.com", "AppGallery"),
        ("apps.microsoft.com", "Microsoft Store"),
        ("pub.dev", "pub.dev"),
        ("github.com", "GitHub"),
    ]:
        if host in url:
            return label
    return url


def month_range(period: str) -> str:
    """'03/2022 - 02/2025' -> 'Mar 2022 – Feb 2025'."""
    months = "Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec".split()

    def one(part: str) -> str:
        m = re.fullmatch(r"(\d{1,2})/(\d{4})", part.strip())
        return f"{months[int(m.group(1)) - 1]} {m.group(2)}" if m else part.strip()

    return " – ".join(one(p) for p in period.split(" - "))


def section(title: str):
    return [
        Paragraph(title.upper(), STYLES["section"]),
        HRFlowable(width="100%", thickness=0.6, color=RULE, spaceBefore=0, spaceAfter=5),
    ]


def bullets(items):
    return ListFlowable(
        [ListItem(Paragraph(text(i), STYLES["bullet"]), leftIndent=11, value="•") for i in items],
        bulletType="bullet",
        bulletFontName="Inter",
        bulletFontSize=8,
        bulletColor=ACCENT,
        leftIndent=11,
        spaceBefore=2,
    )


def heading_row(left: str, right: str):
    """Bold title on the left, muted dates flush right."""
    t = Table(
        [[Paragraph(left, STYLES["role"]), Paragraph(text(right), STYLES["date"])]],
        colWidths=["78%", "22%"],
    )
    t.setStyle(
        TableStyle(
            [
                ("ALIGN", (1, 0), (1, 0), "RIGHT"),
                ("VALIGN", (0, 0), (-1, -1), "BOTTOM"),
                ("LEFTPADDING", (0, 0), (-1, -1), 0),
                ("RIGHTPADDING", (0, 0), (-1, -1), 0),
                ("TOPPADDING", (0, 0), (-1, -1), 0),
                ("BOTTOMPADDING", (0, 0), (-1, -1), 0),
            ]
        )
    )
    return t


def build(cv: dict):
    story = []

    story.append(Paragraph(text(cv["name"]), STYLES["name"]))
    story.append(Paragraph(text(cv["title"]), STYLES["title"]))
    story.append(Spacer(1, 4))
    phone = cv["phone"]
    story.append(
        Paragraph(
            " · ".join(
                [
                    text(cv["location"]),
                    link(f"mailto:{cv['email']}", cv["email"]),
                    link(f"tel:{phone}", phone),
                ]
            ),
            STYLES["contact"],
        )
    )
    story.append(
        Paragraph(
            " · ".join(
                [
                    link(SITE, SITE.removeprefix("https://")),
                    link(cv["linkedin"], cv["linkedin"].removeprefix("https://www.")),
                    link(cv["github"], cv["github"].removeprefix("https://")),
                ]
            ),
            STYLES["contact"],
        )
    )

    story += section("Summary")
    story.append(Paragraph(text(cv["summary"]), STYLES["body"]))

    story += section("Experience")
    for i, exp in enumerate(cv["experience"]):
        block = [
            heading_row(
                f'{text(exp["role"])} <font name="Inter" color="#5A5A75">· {text(exp["company"])}, {text(exp["location"])}</font>',
                month_range(exp["period"]),
            ),
            bullets(exp["highlights"]),
        ]
        if i:
            block.insert(0, Spacer(1, 7))
        story.append(KeepTogether(block))

    story += section("Selected projects")
    for i, project in enumerate(cv["projects"]):
        links = project.get("stores", []) + [u for u in (project.get("link"), project.get("github")) if u]
        title = text(project["name"])
        if links:
            title += ' <font name="Inter" size="8.6" color="#5A5A75">· </font>' + '<font name="Inter" size="8.6"> · </font>'.join(
                link(u, store_label(u)) for u in links
            )
        block = [heading_row(title, month_range(project["period"]))]
        block.append(Paragraph(text(project["description"]), STYLES["body"]))
        highlights = project.get("highlights") or []
        if highlights:
            block.append(bullets(highlights))
        if project.get("technologies"):
            block.append(Paragraph("Built with: " + text(", ".join(project["technologies"])), STYLES["meta"]))
        if i:
            block.insert(0, Spacer(1, 7))
        story.append(KeepTogether(block))

    story += section("Skills")
    story.append(Paragraph(text(" · ".join(cv["skills"])), STYLES["body"]))

    story += section("Education")
    edu = cv["education"]
    story.append(
        heading_row(
            f'{text(edu["degree"])} <font name="Inter" color="#5A5A75">· {text(edu["university"])}</font>',
            month_range(edu["period"]),
        )
    )
    return story


def on_page(canvas, doc):
    canvas.saveState()
    canvas.setFont("Inter", 7.5)
    canvas.setFillColor(MUTED)
    canvas.drawRightString(LETTER[0] - doc.rightMargin, 0.42 * inch, f"Page {doc.page}")
    canvas.restoreState()


def main():
    cv = json.loads((ROOT / "assets/data/cv.json").read_text())
    out = OUTPUTS[0]
    doc = SimpleDocTemplate(
        str(out),
        pagesize=LETTER,
        leftMargin=0.7 * inch,
        rightMargin=0.7 * inch,
        topMargin=0.6 * inch,
        bottomMargin=0.65 * inch,
        title=f"{cv['name']} — Resume",
        author=cv["name"],
        subject=cv["title"],
        creator="tool/build_resume.py",
    )
    doc.build(build(cv), onFirstPage=on_page, onLaterPages=on_page)
    # Build once and copy, so both served files are byte-identical.
    for copy in OUTPUTS[1:]:
        shutil.copyfile(out, copy)
    for path in OUTPUTS:
        print(f"wrote {path.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
