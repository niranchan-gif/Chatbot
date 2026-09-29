from __future__ import annotations

from typing import Any, Dict, List, Sequence

from .nlp_service import cosine_similarity, tokenize


class SearchService:
    """Finds and ranks the most relevant dataset records for a user query."""

    @staticmethod
    def find_relevant_records(
        query: str,
        records: Sequence[Dict[str, Any]],
        top_k: int = 5,
        context_topic: str | None = None,
    ) -> List[Dict[str, Any]]:
        if not records:
            return []

        query_tokens = tokenize(query)
        ranked: List[Dict[str, Any]] = []

        for record in records:
            topic = record.get("topic", "")
            subtopic = record.get("subtopic", "")
            title = record.get("title", "")
            content = record.get("content", "")
            keywords = record.get("keywords", "")
            combined = " ".join([topic, subtopic, title, keywords, content])
            record_tokens = tokenize(combined)

            similarity = cosine_similarity(query_tokens, record_tokens)
            overlap = len(set(query_tokens) & set(record_tokens))
            topic_bonus = 0.25 if context_topic and topic.lower() == context_topic.lower() else 0.0
            score = similarity + (overlap * 0.08) + topic_bonus

            ranked.append({**record, "_score": score})

        ranked.sort(key=lambda item: item["_score"], reverse=True)
        selected = ranked[:top_k]
        for item in selected:
            item.pop("_score", None)
        return selected
