import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SuggestionChips extends StatelessWidget {
  final List<String> suggestions;
  final void Function(String) onTap;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final chip = suggestions[index];
          return _SuggestionChip(
            label: chip,
            onTap: () => onTap(chip),
            isDark: isDark,
            index: index,
          );
        },
      ),
    );
  }
}

class _SuggestionChip extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isDark;
  final int index;

  const _SuggestionChip({
    required this.label,
    required this.onTap,
    required this.isDark,
    required this.index,
  });

  @override
  State<_SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<_SuggestionChip> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
          onEnter: (_) => setState(() => _hovered = true),
          onExit: (_) => setState(() => _hovered = false),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _hovered
                    ? const Color(0xFF4F46E5).withValues(alpha: 0.1)
                    : (widget.isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _hovered
                      ? const Color(0xFF4F46E5).withValues(alpha: 0.5)
                      : (widget.isDark
                            ? const Color(0xFF334155)
                            : const Color(0xFFE2E8F0)),
                ),
              ),
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _hovered
                      ? const Color(0xFF4F46E5)
                      : (widget.isDark
                            ? const Color(0xFFCBD5E1)
                            : const Color(0xFF475569)),
                ),
              ),
            ),
          ),
        )
        .animate(delay: (widget.index * 60).ms)
        .fadeIn(duration: 250.ms)
        .slideX(begin: 0.1, end: 0, duration: 250.ms);
  }
}
