from __future__ import annotations

import csv
from pathlib import Path
from typing import Any, Dict, List


REQUIRED_COLUMNS = {
    "topic",
    "subtopic",
    "content",
    "keywords",
}


class DatasetService:
    """Loads and validates the educational knowledge dataset."""

    def __init__(self, dataset_path: str | Path):
        self.dataset_path = Path(dataset_path)
        self.records: List[Dict[str, Any]] = self._load_dataset()

    def _load_dataset(self) -> List[Dict[str, Any]]:
        if not self.dataset_path.exists():
            raise FileNotFoundError(f"Dataset not found at {self.dataset_path}")

        with self.dataset_path.open("r", encoding="utf-8-sig", newline="") as file:
            reader = csv.DictReader(file)
            if not reader.fieldnames:
                raise ValueError("Dataset is empty or missing a header row.")

            normalized_fieldnames = [
                (field or "").strip().lstrip("\ufeff") for field in reader.fieldnames
            ]
            reader.fieldnames = normalized_fieldnames

            missing = REQUIRED_COLUMNS - set(normalized_fieldnames)
            if missing:
                raise ValueError(
                    "Dataset is missing required columns: " + ", ".join(sorted(missing))
                )

            records: List[Dict[str, Any]] = []
            for index, row in enumerate(reader, start=1):
                cleaned = self._clean_record(row, index)
                if cleaned is not None:
                    records.append(cleaned)

        return records

    def _clean_record(self, row: Dict[str, str], index: int) -> Dict[str, Any] | None:
        topic = (row.get("topic") or "").strip()
        subtopic = (row.get("subtopic") or "").strip()
        title = (row.get("title") or "").strip()
        content = (row.get("content") or "").strip()
        keywords = (row.get("keywords") or "").strip()

        if not topic or not content:
            return None

        record = {
            "id": f"record_{index}",
            "topic": topic,
            "subtopic": subtopic or "Overview",
            "title": title or subtopic or topic,
            "content": content,
            "keywords": keywords,
            "source": row.get("source") or "Dataset",
            "difficulty": (row.get("difficulty") or "medium").strip().lower(),
            "record_type": (row.get("record_type") or "knowledge").strip().lower(),
            "topic_summary": (row.get("topic_summary") or "").strip(),
        }
        return record

    def get_topics(self) -> List[str]:
        return sorted({record["topic"] for record in self.records})

    def get_records_for_topic(self, topic: str) -> List[Dict[str, Any]]:
        normalized = (topic or "").strip().lower()
        return [
            record for record in self.records if (record["topic"]).lower() == normalized
        ]

    def get_topic_summary(self) -> Dict[str, Any]:
        topics = self.get_topics()
        return {
            "topics": len(topics),
            "records": len(self.records),
            "available_topics": topics,
        }
