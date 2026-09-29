from __future__ import annotations

import re
from collections import Counter
from typing import Any, Dict, Iterable, List, Sequence, Tuple


STOPWORDS = {
    "the", "a", "an", "is", "are", "and", "or", "of", "to", "in", "for", "on",
    "with", "by", "as", "it", "its", "that", "this", "be", "from", "was", "were",
    "at", "about", "into", "over", "under", "after", "before", "what", "when",
    "where", "why", "how", "which", "their", "they", "them", "we", "you", "your",
    "his", "her", "our", "has", "have", "had", "can", "could", "should", "would",
    "may", "might", "use", "uses", "used", "using", "not", "but", "if", "then",
    "than", "more", "most", "some", "such", "also", "there", "these", "those",
} 


def normalize_text(text: str) -> str:
    text = text.strip()
    text = text.replace("\n", " ")
    text = re.sub(r"\s+", " ", text)
    return text


def tokenize(text: str) -> List[str]:
    normalized = normalize_text(text).lower()
    tokens = re.findall(r"[a-zA-Z0-9]+", normalized)
    return [token for token in tokens if token not in STOPWORDS]


def extract_keywords(text: str, limit: int = 8) -> List[str]:
    tokens = tokenize(text)
    counts = Counter(tokens)
    ranked = [token for token, _ in counts.most_common(limit)]
    return ranked


def detect_intent(message: str) -> str:
    text = normalize_text(message).lower()

    if re.search(r"\b(quiz|test me|test my knowledge|questions|create questions)\b", text):
        return "QUIZ"
    if re.search(r"\b(summarize|summary|short summary|briefly)\b", text):
        return "SUMMARIZE"
    if re.search(r"\b(example|for example|real-world example|give me an example)\b", text):
        return "EXAMPLE"
    if re.search(r"\b(applications|uses|where is it used|importance|advantages|benefits|pros)\b", text):
        return "APPLICATIONS"
    if re.search(r"\b(disadvantages|drawbacks|limitations|cons|weaknesses)\b", text):
        return "DISADVANTAGES"
    if re.search(r"\b(compare|difference between|vs|versus)\b", text):
        return "COMPARE"
    if re.search(r"\b(explain|what is|what are|define|describe|tell me about)\b", text):
        return "EXPLAIN"
    if re.search(r"\b(advantages|benefits|why it matters|importance)\b", text):
        return "ADVANTAGES"
    return "EXPLAIN"


def cosine_similarity(a_tokens: Sequence[str], b_tokens: Sequence[str]) -> float:
    if not a_tokens or not b_tokens:
        return 0.0

    a_counts = Counter(a_tokens)
    b_counts = Counter(b_tokens)
    dot = sum(a_counts[token] * b_counts.get(token, 0) for token in set(a_counts) & set(b_counts))
    a_norm = sum(count * count for count in a_counts.values()) ** 0.5
    b_norm = sum(count * count for count in b_counts.values()) ** 0.5
    if a_norm == 0 or b_norm == 0:
        return 0.0
    return dot / (a_norm * b_norm)


def detect_topic(query: str, records: Sequence[Dict[str, Any]], context_topic: str | None = None) -> Tuple[str, float]:
    if context_topic:
        context_topic = context_topic.strip()
        if context_topic:
            return context_topic, 0.85

    query_tokens = set(tokenize(query))
    best_topic = "General"
    best_score = 0.0

    for record in records:
        field_text = " ".join(
            [
                record.get("topic", ""),
                record.get("subtopic", ""),
                record.get("title", ""),
                record.get("keywords", ""),
            ]
        )
        field_tokens = set(tokenize(field_text))
        overlap = len(query_tokens & field_tokens)
        score = overlap / max(len(query_tokens), 1)
        if score > best_score:
            best_score = score
            best_topic = str(record.get("topic", "General"))

    if best_score == 0:
        return "General", 0.0
    return best_topic, round(best_score, 2)


def analyze_query(
    message: str,
    records: Sequence[Dict[str, Any]],
    context_topic: str | None = None,
) -> Dict[str, Any]:
    normalized = normalize_text(message)
    intent = detect_intent(normalized)
    topic, topic_confidence = detect_topic(normalized, records, context_topic)
    keywords = extract_keywords(normalized, limit=8)
    sentiment = "neutral"
    if any(word in normalized.lower() for word in ["why", "importance", "advantages", "benefits"]):
        sentiment = "positive"

    return {
        "intent": intent,
        "intent_confidence": 0.86 if intent else 0.5,
        "topic": topic,
        "topic_confidence": topic_confidence,
        "keywords": keywords,
        "sentiment": sentiment,
        "resolved_context": context_topic or topic,
        "entities": [
            {"text": keyword, "type": "KEYWORD", "confidence": 0.8}
            for keyword in keywords[:5]
        ],
    }
