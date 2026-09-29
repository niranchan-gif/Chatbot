class EducationalSource {
  final String title;
  final String provider;
  final String url;
  final String summary;
  final double relevanceScore;
  final String type;

  const EducationalSource({
    required this.title,
    required this.provider,
    required this.url,
    required this.summary,
    required this.relevanceScore,
    required this.type,
  });

  factory EducationalSource.fromJson(Map<String, dynamic> json) {
    return EducationalSource(
      title: json['title'] as String? ?? 'Educational Source',
      provider: json['provider'] as String? ?? 'StudyMate',
      url: json['url'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      relevanceScore:
          (json['relevance_score'] as num?)?.toDouble() ??
          (json['relevanceScore'] as num?)?.toDouble() ??
          0.0,
      type: json['type'] as String? ?? 'resource',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'provider': provider,
      'url': url,
      'summary': summary,
      'relevance_score': relevanceScore,
      'type': type,
    };
  }
}
