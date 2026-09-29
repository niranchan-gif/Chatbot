import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';
import 'source_card.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool showNlpPanel;

  const ChatBubble({
    super.key,
    required this.message,
    this.showNlpPanel = false,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == MessageSender.user;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedOpacity(
      opacity: 1,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: isUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!isUser) ...[
                  _BotAvatar(isDark: isDark),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: _BubbleBody(
                    message: message,
                    isUser: isUser,
                    theme: theme,
                    isDark: isDark,
                  ),
                ),
                if (isUser) ...[
                  const SizedBox(width: 8),
                  _UserAvatar(isDark: isDark),
                ],
              ],
            ),
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: isUser ? 0 : 44,
                right: isUser ? 44 : 0,
              ),
              child: Text(
                _formatTime(message.timestamp),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour < 12 ? 'AM' : 'PM';
    return '$h:$m $period';
  }
}

class _BotAvatar extends StatelessWidget {
  final bool isDark;
  const _BotAvatar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryIndigo, AppTheme.accentPurple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  final bool isDark;
  const _UserAvatar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.person_rounded,
        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
        size: 18,
      ),
    );
  }
}

class _BubbleBody extends StatelessWidget {
  final ChatMessage message;
  final bool isUser;
  final ThemeData theme;
  final bool isDark;

  const _BubbleBody({
    required this.message,
    required this.isUser,
    required this.theme,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isUser
        ? AppTheme.primaryIndigo
        : (isDark ? const Color(0xFF1E293B) : Colors.white);

    final textColor = isUser
        ? Colors.white
        : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B));

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 18),
    );

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.72,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: borderRadius,
        border: isUser
            ? null
            : Border.all(
                color: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFE2E8F0),
                width: 1,
              ),
        boxShadow: [
          BoxShadow(
            color: (isUser ? AppTheme.primaryIndigo : Colors.black).withValues(
              alpha: isUser ? 0.2 : 0.05,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isError)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Error',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            _buildMessageText(message.text, textColor),
            if (!isUser && (message.keyPoints ?? const []).isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Key Points',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(message.keyPoints!.length, (index) {
                final point = message.keyPoints![index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 7),
                        child: Icon(
                          Icons.circle,
                          size: 7,
                          color: textColor.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          point,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            if (!isUser && (message.sources ?? const []).isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Sources',
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(message.sources!.length, (index) {
                final source = message.sources![index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SourceCard(source: source),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageText(String text, Color textColor) {
    // Simple code block renderer
    if (text.contains('```')) {
      final parts = text.split('```');
      final List<Widget> children = [];
      for (int i = 0; i < parts.length; i++) {
        if (i.isEven) {
          // Regular text
          final trimmed = parts[i].trim();
          if (trimmed.isNotEmpty) {
            children.add(
              Text(
                trimmed,
                style: TextStyle(color: textColor, fontSize: 15, height: 1.55),
              ),
            );
            if (i < parts.length - 1) {
              children.add(const SizedBox(height: 8));
            }
          }
        } else {
          // Code block
          final code = parts[i].trim();
          // Strip language identifier from first line if present
          final lines = code.split('\n');
          final codeContent = lines.length > 1 && !lines[0].contains(' ')
              ? lines.sublist(1).join('\n')
              : code;

          children.add(
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                codeContent.trim(),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Color(0xFF7DD3FC),
                  height: 1.6,
                ),
              ),
            ),
          );
          if (i < parts.length - 1) {
            children.add(const SizedBox(height: 4));
          }
        }
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      );
    }

    return Text(
      text,
      style: TextStyle(color: textColor, fontSize: 15, height: 1.55),
    );
  }
}
