import 'package:flutter/material.dart';

import '../models/chat_message.dart';
import '../services/api_service.dart';
import '../services/mock_chat_service.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  final String mode;

  const ChatScreen({super.key, required this.mode});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final MockChatService _fallbackService = MockChatService();
  final List<ChatMessage> _messages = [];

  bool _isTyping = false;
  List<String> _currentSuggestions = [];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        text:
            'Ask me about any concept you want to learn. I will retrieve the best external educational source and summarize it clearly for you.',
        sender: MessageSender.bot,
        timestamp: DateTime.now(),
      ),
    );
    _currentSuggestions = const [];
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _isTyping = true;
      _currentSuggestions = [];
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final isHealthy = await _apiService.isBackendHealthy();
      final botMessage = isHealthy
          ? (await _apiService.sendMessage(
              text,
              mode: widget.mode,
              includeNlpAnalysis: true,
            )).toChatMessage()
          : null;

      if (!mounted) return;

      if (botMessage != null && !botMessage.isError) {
        setState(() {
          _messages.add(botMessage);
          _isTyping = false;
          _currentSuggestions = botMessage.suggestions ?? [];
        });
      } else {
        final fallbackMessage = await _fallbackService.sendMessage(
          text,
          widget.mode,
        );
        setState(() {
          _messages.add(fallbackMessage);
          _isTyping = false;
          _currentSuggestions = fallbackMessage.suggestions ?? [];
        });
      }
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;

      try {
        final fallbackMessage = await _fallbackService.sendMessage(
          text,
          widget.mode,
        );
        setState(() {
          _messages.add(fallbackMessage);
          _isTyping = false;
          _currentSuggestions = fallbackMessage.suggestions ?? [];
        });
      } catch (_) {
        setState(() {
          _isTyping = false;
          _messages.add(
            ChatMessage(
              text: 'Unable to connect to StudyMate. Please try again.',
              sender: MessageSender.bot,
              timestamp: DateTime.now(),
              isError: true,
            ),
          );
        });
      }
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome_rounded),
            const SizedBox(width: 8),
            Text('${widget.mode} Mode'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length && _isTyping) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const TypingIndicator(),
                              const SizedBox(width: 12),
                              Text(
                                'StudyMate is thinking...',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return ChatBubble(message: _messages[index]);
                },
              ),
            ),
            if (_currentSuggestions.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: SizedBox(
                  height: 46,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _currentSuggestions.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final suggestion = _currentSuggestions[index];
                      return ActionChip(
                        label: Text(suggestion),
                        onPressed: () => _sendMessage(suggestion),
                      );
                    },
                  ),
                ),
              ),
            MessageInput(
              controller: _textController,
              onSend: () => _sendMessage(_textController.text),
              onSubmitted: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
