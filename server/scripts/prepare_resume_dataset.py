import argparse
import json
from pathlib import Path
from typing import Dict, Iterable, List

import kagglehub
import pandas as pd


DATASET_SLUG = "suriyaganesh/resume-dataset-structured"


def _clean(value: object) -> str:
    if pd.isna(value):
        return ""
    return str(value).strip()


def _join_limited(values: Iterable[str], limit: int) -> str:
    cleaned = [value for value in values if value]
    return ", ".join(cleaned[:limit])


def _format_resume_sample(
    name: str,
    education_items: List[str],
    experience_items: List[str],
    skill_items: List[str],
) -> Dict[str, str]:
    target_position = name or "Resume Candidate"
    education = "；".join(education_items) if education_items else "Education not provided"
    experience = "；".join(experience_items) if experience_items else "Experience not provided"
    skills = _join_limited(skill_items, 12) or "Skills not provided"
    project_experience = (
        "Use the listed professional experience and skills to present a truthful project or work highlight."
    )
    prompt = (
        "Generate a concise, truthful resume based only on the given structured data.\n"
        f"Target position: {target_position}\n"
        f"Education: {education}\n"
        f"Skills: {skills}\n"
        f"Experience: {experience}\n"
        "Do not invent schools, companies, certificates, years, or achievements.\n"
        "Resume:"
    )
    response = (
        f"Target Position: {target_position}\n\n"
        f"Education:\n{education}\n\n"
        f"Core Skills:\n{skills}\n\n"
        f"Experience:\n{experience}\n\n"
        f"Project / Work Highlight:\n{project_experience}"
    )
    return {
        "prompt": prompt,
        "response": response,
        "targetPosition": target_position,
        "education": education,
        "skills": skills,
        "workExperience": experience,
    }


def build_training_jsonl(dataset_dir: Path, output_path: Path, max_samples: int) -> int:
    people = pd.read_csv(dataset_dir / "01_people.csv")
    education = pd.read_csv(dataset_dir / "03_education.csv")
    experience = pd.read_csv(dataset_dir / "04_experience.csv")
    person_skills = pd.read_csv(dataset_dir / "05_person_skills.csv")

    education_map: Dict[int, List[str]] = {}
    for row in education.itertuples(index=False):
        person_id = int(row.person_id)
        institution = _clean(row.institution)
        program = _clean(row.program)
        location = _clean(row.location)
        parts = [part for part in [institution, program, location] if part]
        if parts:
            education_map.setdefault(person_id, []).append(" - ".join(parts))

    experience_map: Dict[int, List[str]] = {}
    for row in experience.itertuples(index=False):
        person_id = int(row.person_id)
        title = _clean(row.title)
        firm = _clean(row.firm)
        location = _clean(row.location)
        date_range = " to ".join(
            part for part in [_clean(row.start_date), _clean(row.end_date)] if part
        )
        parts = [part for part in [title, firm, date_range, location] if part]
        if parts:
            experience_map.setdefault(person_id, []).append(" - ".join(parts))

    skills_map: Dict[int, List[str]] = {}
    for row in person_skills.itertuples(index=False):
        person_id = int(row.person_id)
        skill = _clean(row.skill)
        if skill:
            skills_map.setdefault(person_id, []).append(skill)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    count = 0
    with output_path.open("w", encoding="utf-8") as output_file:
        for row in people.itertuples(index=False):
            person_id = int(row.person_id)
            if person_id not in education_map or person_id not in experience_map:
                continue
            sample = _format_resume_sample(
                name=_clean(row.name),
                education_items=education_map.get(person_id, [])[:3],
                experience_items=experience_map.get(person_id, [])[:4],
                skill_items=skills_map.get(person_id, [])[:24],
            )
            output_file.write(json.dumps(sample, ensure_ascii=False) + "\n")
            count += 1
            if count >= max_samples:
                break
    return count


def main() -> None:
    parser = argparse.ArgumentParser(description="Download and prepare a structured resume dataset.")
    parser.add_argument("--output", default="server/data/processed/resume_train.jsonl")
    parser.add_argument("--max-samples", type=int, default=800)
    args = parser.parse_args()

    dataset_path = Path(kagglehub.dataset_download(DATASET_SLUG))
    output_path = Path(args.output)
    sample_count = build_training_jsonl(dataset_path, output_path, args.max_samples)

    metadata_path = output_path.with_suffix(".metadata.json")
    metadata = {
        "datasetName": "54k Resume dataset structured",
        "source": f"https://www.kaggle.com/datasets/{DATASET_SLUG}",
        "kaggleHubPath": str(dataset_path),
        "outputPath": str(output_path),
        "sampleCount": sample_count,
        "usage": "Small-sample language-model fine-tuning and resume-generation evaluation.",
    }
    metadata_path.write_text(json.dumps(metadata, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(metadata, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
