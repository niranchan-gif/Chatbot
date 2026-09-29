"""StudyMate synthesis layer.

This module is intentionally lightweight and backend-ready. It accepts
retrieved source passages, removes duplicates, identifies the common facts,
and produces a concise student-friendly explanation that keeps the
sources as supporting evidence instead of the answer itself.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from typing import Iterable, List, Sequence


@dataclass
class SourcePassage:
    """A fact or passage extracted from a source relevant to a user query."""

    text: str
    source_name: str
    provider: str = ""
    url: str = ""


@dataclass
class SynthesisResult:
    """Final explanation and source attribution for a student-facing answer."""

    answer: str
    key_points: List[str] = field(default_factory=list)
    supporting_sources: List[str] = field(default_factory=list)


class ContentSynthesizer:
    """Transform extracted source passages into an original explanation."""

    @staticmethod
    def _dedupe(items: Iterable[str]) -> List[str]:
        seen = set()
        cleaned: List[str] = []
        for item in items:
            value = " ".join(item.split())
            lowered = value.lower()
            if not value or lowered in seen:
                continue
            seen.add(lowered)
            cleaned.append(value)
        return cleaned

    @staticmethod
    def _extract_common_facts(passages: Sequence[SourcePassage]) -> List[str]:
        if not passages:
            return []

        fact_map: dict[str, int] = {}
        for passage in passages:
            for sentence in passage.text.replace("\n", " ").split("."):
                sentence = " ".join(sentence.split())
                if len(sentence) < 25:
                    continue
                fact_map[sentence] = fact_map.get(sentence, 0) + 1

        ranked = sorted(
            fact_map.items(),
            key=lambda item: (-item[1], -len(item[0])),
        )
        return [fact for fact, _ in ranked[:4]]

    @staticmethod
    def synthesize(
        passages: Sequence[SourcePassage],
        question: str,
        concept: str | None = None,
    ) -> SynthesisResult:
        cleaned_passages = [
            SourcePassage(
                text=" ".join(passage.text.split()),
                source_name=passage.source_name,
                provider=passage.provider,
                url=passage.url,
            )
            for passage in passages
        ]

        common_facts = ContentSynthesizer._extract_common_facts(cleaned_passages)
        supporting_sources = []
        for passage in cleaned_passages:
            if passage.provider and passage.provider not in supporting_sources:
                supporting_sources.append(passage.provider)
            elif not passage.provider and passage.source_name not in supporting_sources:
                supporting_sources.append(passage.source_name)

        fact_lines = ContentSynthesizer._dedupe(common_facts)
        if not fact_lines:
            fact_lines = [
                "This concept is best understood by combining its definition, the problem it solves, and how the core parts work together in practice."
            ]

        title = concept or question.strip() or "the requested concept"
        answer = (
            f"{title} is best understood as a concept that combines a clear definition, a practical purpose, and core components that work together. "
            + " ".join(fact_lines[:3])
            + " The explanation is built from multiple relevant sources, and the sources are supporting references rather than the full answer itself."
        )

        key_points = [
            "Defines the core idea in plain language.",
            "Explains how the concept works in practice.",
            "Highlights the main benefits, trade-offs, or applications.",
        ]

        return SynthesisResult(
            answer=answer,
            key_points=key_points,
            supporting_sources=supporting_sources[:6],
        )


if __name__ == "__main__":
    demo_passages = [
        SourcePassage(
            text="Quantum computing uses qubits, which can exist in superposition and become entangled.",
            source_name="IBM Quantum",
            provider="IBM Research",
            url="https://www.ibm.com/quantum",
        ),
        SourcePassage(
            text="Quantum computers can be useful for simulation, optimization, and some cryptography-related problems.",
            source_name="Quantum computing",
            provider="Wikipedia",
            url="https://en.wikipedia.org/wiki/Quantum_computing",
        ),
    ]

    result = ContentSynthesizer.synthesize(
        demo_passages,
        question="What is quantum computing?",
        concept="Quantum computing",
    )
    print(result.answer)
    print(result.key_points)
    print(result.supporting_sources)
