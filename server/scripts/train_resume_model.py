import argparse
import json
from pathlib import Path
from typing import Dict, List

import torch
from torch.utils.data import Dataset
from transformers import (
    AutoModelForCausalLM,
    AutoTokenizer,
    DataCollatorForLanguageModeling,
    Trainer,
    TrainingArguments,
)


DEFAULT_BASE_MODEL = "sshleifer/tiny-gpt2"


class JsonlTextDataset(Dataset):
    def __init__(self, jsonl_path: Path, tokenizer: AutoTokenizer, max_length: int, sample_limit: int) -> None:
        self.items: List[Dict[str, torch.Tensor]] = []
        with jsonl_path.open("r", encoding="utf-8") as input_file:
            for line in input_file:
                if len(self.items) >= sample_limit:
                    break
                data = json.loads(line)
                text = f"{data['prompt']}\n{data['response']}{tokenizer.eos_token}"
                encoded = tokenizer(
                    text,
                    truncation=True,
                    max_length=max_length,
                    padding=False,
                    return_tensors=None,
                )
                self.items.append(
                    {
                        "input_ids": torch.tensor(encoded["input_ids"], dtype=torch.long),
                        "attention_mask": torch.tensor(encoded["attention_mask"], dtype=torch.long),
                    }
                )

    def __len__(self) -> int:
        return len(self.items)

    def __getitem__(self, index: int) -> Dict[str, torch.Tensor]:
        return self.items[index]


def main() -> None:
    parser = argparse.ArgumentParser(description="Run a lightweight resume-generation fine-tuning job.")
    parser.add_argument("--data", default="server/data/processed/resume_train.jsonl")
    parser.add_argument("--output-dir", default="server/artifacts/resume_tiny_model")
    parser.add_argument("--base-model", default=DEFAULT_BASE_MODEL)
    parser.add_argument("--sample-limit", type=int, default=96)
    parser.add_argument("--max-steps", type=int, default=20)
    parser.add_argument("--max-length", type=int, default=384)
    args = parser.parse_args()

    data_path = Path(args.data)
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    tokenizer = AutoTokenizer.from_pretrained(args.base_model)
    if tokenizer.pad_token is None:
        tokenizer.pad_token = tokenizer.eos_token

    model = AutoModelForCausalLM.from_pretrained(args.base_model)
    dataset = JsonlTextDataset(data_path, tokenizer, args.max_length, args.sample_limit)
    if len(dataset) == 0:
        raise RuntimeError(f"No training samples found in {data_path}")

    use_mps = torch.backends.mps.is_available()
    training_args = TrainingArguments(
        output_dir=str(output_dir),
        overwrite_output_dir=True,
        max_steps=args.max_steps,
        per_device_train_batch_size=1,
        gradient_accumulation_steps=2,
        learning_rate=5e-5,
        logging_steps=5,
        save_steps=args.max_steps,
        save_total_limit=1,
        report_to=[],
        use_mps_device=use_mps,
        fp16=False,
        bf16=False,
    )
    trainer = Trainer(
        model=model,
        args=training_args,
        train_dataset=dataset,
        data_collator=DataCollatorForLanguageModeling(tokenizer=tokenizer, mlm=False),
    )
    trainer.train()
    trainer.save_model(str(output_dir))
    tokenizer.save_pretrained(str(output_dir))

    metadata = {
        "baseModel": args.base_model,
        "outputDir": str(output_dir),
        "sampleLimit": args.sample_limit,
        "maxSteps": args.max_steps,
        "maxLength": args.max_length,
        "device": "mps" if use_mps else "cpu",
        "note": "Tiny local fine-tuning run for coursework demonstration; quality depends on model size and steps.",
    }
    (output_dir / "training_metadata.json").write_text(
        json.dumps(metadata, ensure_ascii=False, indent=2),
        encoding="utf-8",
    )
    print(json.dumps(metadata, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
