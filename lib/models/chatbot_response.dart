import '../models/chat_message.dart';
import '../models/educational_source.dart';
import '../models/nlp_analysis.dart';

/// Chatbot response as received from the Flask API.
class ChatbotResponse {
  final String text;
  final List<String> suggestions;
  final NlpAnalysis? nlpAnalysis;
  final List<String> keyPoints;
  final List<EducationalSource>? sources;
  final bool isError;

  const ChatbotResponse({
    required this.text,
    required this.suggestions,
    this.nlpAnalysis,
    this.keyPoints = const [],
    this.sources,
    this.isError = false,
  });

  factory ChatbotResponse.fromJson(Map<String, dynamic> json) {
    NlpAnalysis? nlp;
    if (json['nlp_analysis'] != null) {
      nlp = NlpAnalysis.fromJson(json['nlp_analysis'] as Map<String, dynamic>);
    }

    final rawSources = (json['sources'] as List<dynamic>? ?? [])
        .map((e) => EducationalSource.fromJson(e as Map<String, dynamic>))
        .toList();

    return ChatbotResponse(
      text: json['response'] as String? ?? json['answer'] as String? ?? '',
      suggestions: List<String>.from(
        json['suggestions'] as List<dynamic>? ?? [],
      ),
      nlpAnalysis: nlp,
      keyPoints: List<String>.from(json['key_points'] as List<dynamic>? ?? []),
      sources: rawSources,
    );
  }

  ChatMessage toChatMessage() {
    return ChatMessage(
      text: text,
      sender: MessageSender.bot,
      timestamp: DateTime.now(),
      isError: isError,
      suggestions: suggestions,
      nlpAnalysis: nlpAnalysis,
      keyPoints: keyPoints,
      sources: sources,
    );
  }

  factory ChatbotResponse.error(String message) {
    return ChatbotResponse(text: message, suggestions: [], isError: true);
  }
}
