from __future__ import annotations

import os
from pathlib import Path
from typing import Any, Dict, List

from flask import Flask, jsonify, request

from services.conversation_service import ConversationService
from services.dataset_service import DatasetService
from services.nlp_service import analyze_query, normalize_text
from services.quiz_service import QuizService
from services.search_service import SearchService
from services.summarizer import Summarizer


app = Flask(__name__)


@app.after_request
def add_cors_headers(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, PUT, DELETE, OPTIONS"
    return response


BASE_DIR = Path(__file__).resolve().parent
DATASET_PATH = BASE_DIR / "data" / "knowledge_dataset.csv"

# Load dataset on startup
try:
    dataset_service = DatasetService(DATASET_PATH)
except FileNotFoundError:
    dataset_service = None

conversation_service = ConversationService()


@app.get("/health")
def health():
    return jsonify({"status": "ok", "dataset_loaded": dataset_service is not None})


@app.post("/conversation/reset")
def reset_conversation():
    payload = request.get_json(silent=True) or {}
    conversation_id = str(payload.get("conversation_id") or payload.get("session_id") or "")
    if conversation_id:
        conversation_service.reset(conversation_id)
    return jsonify({"status": "reset"})


@app.post("/chat")
def chat():
    payload = request.get_json(silent=True) or {}
    message = str(payload.get("message") or "").strip()
    conversation_id = str(payload.get("conversation_id") or payload.get("session_id") or "default")
    mode = str(payload.get("mode") or "explain").lower()

    if not message:
        return jsonify({"error": "Message is required."}), 400

    if dataset_service is None:
        return jsonify({
            "answer": "I couldn't load the dataset. Please ensure the backend data file exists.",
            "topic": "Unknown",
            "intent": "UNKNOWN",
            "confidence": 0.0,
            "context_used": False,
            "sources": [],
        })

    context = conversation_service.get_context(conversation_id)
    last_topic = str(context.get("last_topic") or "")
    analysis = analyze_query(message, dataset_service.records, last_topic)
    relevant_records = SearchService.find_relevant_records(
        message,
        dataset_service.records,
        top_k=5,
        context_topic=last_topic or analysis.get("topic"),
    )

    if not relevant_records:
        related = dataset_service.get_topics()[:5]
        return jsonify({
            "answer": "I couldn't find enough relevant information in the knowledge dataset to answer this accurately.",
            "topic": analysis.get("topic") or "Unknown",
            "intent": analysis.get("intent") or "UNKNOWN",
            "confidence": analysis.get("intent_confidence", 0.0),
            "context_used": bool(last_topic),
            "sources": [],
            "related_topics": related,
        })

    response = Summarizer.build_response(
        topic=analysis.get("topic") or "General",
        records=relevant_records,
        intent=analysis.get("intent") or "EXPLAIN",
        user_message=message,
    )

    conversation_service.add_message(conversation_id, message)
    conversation_service.set_topic(conversation_id, analysis.get("topic") or last_topic or "General")

    return jsonify({
        "answer": response["answer"],
        "topic": analysis.get("topic") or "General",
        "intent": analysis.get("intent") or "EXPLAIN",
        "confidence": analysis.get("intent_confidence", 0.8),
        "context_used": bool(last_topic),
        "sources": response.get("sources", []),
        "key_points": response.get("key_points", []),
        "nlp_analysis": {
            "intent": analysis.get("intent"),
            "keywords": analysis.get("keywords"),
            "topic": analysis.get("topic"),
            "resolved_context": analysis.get("resolved_context"),
            "confidence": analysis.get("intent_confidence"),
        },
    })


@app.post("/quiz")
def quiz():
    payload = request.get_json(silent=True) or {}
    conversation_id = str(payload.get("conversation_id") or "default")
    topic = str(payload.get("topic") or "").strip() or "General"
    difficulty = str(payload.get("difficulty") or "medium").lower()
    count = int(payload.get("count") or 5)

    if dataset_service is None:
        return jsonify({"topic": topic, "questions": []})

    topic_records = dataset_service.get_records_for_topic(topic)
    if not topic_records:
        topic_records = SearchService.find_relevant_records(topic, dataset_service.records, top_k=count)

    quiz = QuizService.generate_quiz(topic, topic_records, difficulty=difficulty, count=max(1, min(10, count)))
    return jsonify({"topic": topic, "questions": quiz})


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "5000"))
    app.run(host="0.0.0.0", port=port, debug=True)
