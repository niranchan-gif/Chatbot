from __future__ import annotations

from collections import defaultdict, deque
from typing import Deque, Dict, List, Optional


class ConversationService:
    """Maintains recent chat context for follow-up questions."""

    def __init__(self):
        self._history: Dict[str, Deque[str]] = defaultdict(deque)
        self._topics: Dict[str, str] = {}

    def add_message(self, conversation_id: str, message: str) -> None:
        if not conversation_id:
            return
        self._history[conversation_id].append(message)
        while len(self._history[conversation_id]) > 10:
            self._history[conversation_id].popleft()

    def set_topic(self, conversation_id: str, topic: str) -> None:
        if conversation_id:
            self._topics[conversation_id] = topic

    def get_context(self, conversation_id: str) -> Dict[str, object]:
        recent = list(self._history.get(conversation_id, deque()))
        return {
            "recent_messages": recent,
            "last_topic": self._topics.get(conversation_id, ""),
        }

    def reset(self, conversation_id: str) -> None:
        self._history.pop(conversation_id, None)
        self._topics.pop(conversation_id, None)
