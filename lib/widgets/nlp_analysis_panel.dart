import 'package:flutter/material.dart';

import '../models/nlp_analysis.dart';

class NlpAnalysisPanel extends StatelessWidget {
  final String userInput;
  final NlpAnalysis analysis;

  const NlpAnalysisPanel({
    super.key,
    required this.userInput,
    required this.analysis,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pipeline = [
      ('Input', userInput),
      ('Text Processing', 'Tokenization • Normalization • Stop-word removal'),
      ('Intent Detection', analysis.intent),
      ('Entity Extraction', _formatEntities(analysis.entities)),
      (
        'Context',
        analysis.resolvedContext.isEmpty
            ? 'New Topic'
            : analysis.resolvedContext,
      ),
      ('Response', 'Knowledge retrieval + response generation'),
    ];

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NLP ANALYSIS',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            _DetailRow(
              label: 'Input',
              value: userInput,
              accent: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            ...pipeline.skip(1).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _PipelineStep(title: item.$1, detail: item.$2),
              );
            }),
            const SizedBox(height: 8),
            Divider(color: theme.colorScheme.outlineVariant),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('Intent:', style: theme.textTheme.labelLarge),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    analysis.intent.toUpperCase(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _DetailRow(
              label: 'Confidence',
              value: '${(analysis.intentConfidence * 100).round()}%',
              accent: theme.colorScheme.tertiary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatEntities(List<DetectedEntity> entities) {
    if (entities.isEmpty) return 'None detected';
    return entities.map((e) => e.text).join(', ');
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _PipelineStep extends StatelessWidget {
  final String title;
  final String detail;

  const _PipelineStep({required this.title, required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 6, right: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                detail,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
