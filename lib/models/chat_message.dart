import 'educational_source.dart';
import 'nlp_analysis.dart';

enum MessageSender { user, bot }

class ChatMessage {
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final bool isError;
  final List<String>? suggestions;
  final NlpAnalysis? nlpAnalysis;
  final List<EducationalSource>? sources;
  final List<String>? keyPoints;

  ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
    this.isError = false,
    this.suggestions,
    this.nlpAnalysis,
    this.sources,
    this.keyPoints,
  });
}
