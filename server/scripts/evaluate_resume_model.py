import argparse
import json
import time
from pathlib import Path
from typing import Dict, List

from transformers import pipeline


def load_samples(path: Path, limit: int) -> List[Dict[str, str]]:
    samples: List[Dict[str, str]] = []
    with path.open("r", encoding="utf-8") as input_file:
        for line in input_file:
            samples.append(json.loads(line))
            if len(samples) >= limit:
                break
    return samples


def main() -> None:
    parser = argparse.ArgumentParser(description="Evaluate a local resume-generation model.")
    parser.add_argument("--model-dir", default="server/artifacts/resume_tiny_model")
    parser.add_argument("--data", default="server/data/processed/resume_train.jsonl")
    parser.add_argument("--output", default="server/training_runs/resume_eval.json")
    parser.add_argument("--limit", type=int, default=5)
    parser.add_argument("--max-new-tokens", type=int, default=120)
    args = parser.parse_args()

    model_dir = Path(args.model_dir)
    samples = load_samples(Path(args.data), args.limit)
    generator = pipeline("text-generation", model=str(model_dir), tokenizer=str(model_dir))

    results = []
    total_ms = 0
    for sample in samples:
        start = time.perf_counter()
        output = generator(
            sample["prompt"],
            max_new_tokens=args.max_new_tokens,
            do_sample=False,
            pad_token_id=generator.tokenizer.eos_token_id,
        )[0]["generated_text"]
        elapsed_ms = int((time.perf_counter() - start) * 1000)
        total_ms += elapsed_ms
        generated = output.replace(sample["prompt"], "").strip()
        results.append(
            {
                "targetPosition": sample["targetPosition"],
                "elapsedMs": elapsed_ms,
                "containsTargetPosition": sample["targetPosition"] in generated,
                "generatedPreview": generated[:500],
            }
        )

    report = {
        "modelDir": str(model_dir),
        "sampleCount": len(results),
        "averageElapsedMs": int(total_ms / max(len(results), 1)),
        "results": results,
    }
    output_path = Path(args.output)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")
    print(json.dumps(report, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
