/// Represents a single detected entity in user input.
class DetectedEntity {
  final String text;
  final String type; // e.g. "TOPIC", "CONCEPT", "LANGUAGE", "OPERATION"
  final double confidence;

  const DetectedEntity({
    required this.text,
    required this.type,
    required this.confidence,
  });

  factory DetectedEntity.fromJson(Map<String, dynamic> json) {
    return DetectedEntity(
      text: json['text'] as String,
      type: json['type'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }
}

/// Stores the full NLP analysis of a single user message.
class NlpAnalysis {
  final String intent;
  final double intentConfidence;
  final List<DetectedEntity> entities;
  final String resolvedContext;
  final String sentiment;
  final List<String> keywords;
  final Map<String, double> intentScores;

  const NlpAnalysis({
    required this.intent,
    required this.intentConfidence,
    required this.entities,
    required this.resolvedContext,
    required this.sentiment,
    required this.keywords,
    required this.intentScores,
  });

  factory NlpAnalysis.fromJson(Map<String, dynamic> json) {
    final entitiesList = (json['entities'] as List<dynamic>? ?? [])
        .map((e) => DetectedEntity.fromJson(e as Map<String, dynamic>))
        .toList();

    final rawScores =
        (json['intent_scores'] as Map<String, dynamic>? ?? {});
    final intentScores = rawScores
        .map((k, v) => MapEntry(k, (v as num).toDouble()));

    return NlpAnalysis(
      intent: json['intent'] as String? ?? 'unknown',
      intentConfidence:
          (json['intent_confidence'] as num?)?.toDouble() ?? 0.0,
      entities: entitiesList,
      resolvedContext: json['resolved_context'] as String? ?? '',
      sentiment: json['sentiment'] as String? ?? 'neutral',
      keywords: List<String>.from(json['keywords'] as List<dynamic>? ?? []),
      intentScores: intentScores,
    );
  }
}
