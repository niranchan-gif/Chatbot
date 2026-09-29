from __future__ import annotations

import random
from typing import Any, Dict, List


class QuizService:
    """Generates dataset-backed quiz questions for the relevant topic."""

    @staticmethod
    def generate_quiz(
        topic: str,
        records: List[Dict[str, Any]],
        difficulty: str = "medium",
        count: int = 5,
    ) -> List[Dict[str, Any]]:
        if not records:
            return []

        selected = records[: max(1, min(len(records), count))]
        questions: List[Dict[str, Any]] = []

        for index, record in enumerate(selected, start=1):
            content = (record.get("content") or "").strip()
            if not content:
                continue

            sentence = content.split(".")[0].strip()
            if len(sentence) < 20:
                sentence = content[:140]

            correct = sentence
            distractors = [
                "This concept is unrelated to the topic and has no practical applications.",
                "The idea is only used for storage and not for understanding data or systems.",
                "It is a purely theoretical concept with no impact on real systems.",
            ]

            options = [correct]
            for item in distractors:
                if item not in options:
                    options.append(item)
            random.shuffle(options)
            answer_index = options.index(correct)

            questions.append(
                {
                    "question": f"Which statement best describes {record.get('title', topic)}?",
                    "options": [chr(65 + i) + ". " + option for i, option in enumerate(options)],
                    "answer": chr(65 + answer_index),
                    "explanation": f"The dataset explains that {sentence}",
                }
            )

        if not questions:
            questions.append(
                {
                    "question": f"What is the main idea behind {topic}?",
                    "options": [
                        "A. It is a core concept in the selected learning topic.",
                        "B. It is unrelated to the dataset.",
                        "C. It is only a random phrase.",
                        "D. It does not have any educational value.",
                    ],
                    "answer": "A",
                    "explanation": f"The dataset relates {topic} to the educational content and learning objectives.",
                }
            )

        return questions[:count]
