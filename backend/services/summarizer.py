from __future__ import annotations

import re
from typing import Any, Dict, List, Sequence


class Summarizer:
    """Builds concise student-friendly explanations from retrieved records."""

    @staticmethod
    def _split_sentences(text: str) -> List[str]:
        return [sentence.strip() for sentence in re.split(r"(?<=[.!?])\s+", text) if sentence.strip()]

    @staticmethod
    def _pick_key_points(records: Sequence[Dict[str, Any]], limit: int = 4) -> List[str]:
        points: List[str] = []
        for record in records:
            content = (record.get("content") or "").strip()
            sentences = Summarizer._split_sentences(content)
            if not sentences:
                continue
            sentence = sentences[0]
            sentence = sentence.strip()
            if sentence not in points:
                points.append(sentence)
            if len(points) >= limit:
                break
        return points

    @staticmethod
    def _build_explanation(topic: str, records: Sequence[Dict[str, Any]], intent: str) -> str:
        if not records:
            return (
                "I couldn't find enough relevant information in the knowledge dataset to answer this accurately. "
                "Please try a related topic or ask for a different concept."
            )

        primary = records[0]
        content = primary.get("content") or ""
        sentences = Summarizer._split_sentences(content)
        if not sentences:
            return f"{topic} is a topic in the dataset. The most relevant content is available in the retrieved learning records."

        lead = sentences[0]
        if intent == "SUMMARIZE":
            return lead

        if intent == "EXAMPLE":
            return (
                f"An example related to {topic} is that {lead}. This shows how the concept is applied in a real educational or technical setting."
            )

        if intent == "APPLICATIONS":
            return (
                f"{topic} is important because {lead} It is commonly used in practical applications where understanding patterns, language, or systems matters."
            )

        if intent == "DISADVANTAGES":
            return (
                f"While {topic} is useful, a practical limitation is that {lead} The value of the concept depends on context, data quality, and implementation choices."
            )

        if intent == "COMPARE":
            return (
                f"{topic} can be understood by comparing its main ideas and trade-offs. In the dataset, the key point is that {lead}"
            )

        if intent == "QUIZ":
            return lead

        # Default explanation
        return (
            f"{topic} is a concept in the educational dataset that is explained as follows: {lead}. "
            "The main idea is to understand how the concept works, where it is applied, and why it matters in practice."
        )

    @staticmethod
    def build_response(
        topic: str,
        records: Sequence[Dict[str, Any]],
        intent: str,
        user_message: str,
    ) -> Dict[str, Any]:
        explanation = Summarizer._build_explanation(topic, records, intent)
        key_points = Summarizer._pick_key_points(records, limit=4)

        return {
            "answer": explanation,
            "key_points": key_points,
            "sources": [
                {
                    "title": record.get("title") or record.get("topic"),
                    "provider": record.get("source") or "Knowledge Base",
                    "url": "",
                    "summary": (record.get("content") or "")[:160],
                    "relevanceScore": 0.9,
                    "type": "dataset",
                }
                for record in records[:3]
            ],
        }
