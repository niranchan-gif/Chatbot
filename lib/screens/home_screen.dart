import 'package:flutter/material.dart';

import '../services/ticketbot_service.dart';

const _ink = Color(0xFF172B4D);
const _navy = Color(0xFF102A43);
const _blue = Color(0xFF1769AA);
const _blueTint = Color(0xFFEAF3FA);
const _muted = Color(0xFF62758A);
const _line = Color(0xFFE1E8EF);
const _canvas = Color(0xFFF4F7FA);
const _green = Color(0xFF21865B);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TicketBotService _service = TicketBotService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();
  final List<_ConversationEntry> _conversation = [
    _ConversationEntry(
      text:
          "Hello! I'm TicketBot, your ticket booking support assistant.\n\nI can help with booking, cancellations, refunds, payments, ticket details, and rescheduling. What can I help you with today?",
      isUser: false,
    ),
  ];

  TicketBotResponse? _latestAnalysis;
  String _latestQuestion = '';
  bool _sensitiveInputWasRedacted = false;

  void _sendMessage([String? prompt]) {
    final text = (prompt ?? _messageController.text).trim();
    if (text.isEmpty) return;
    final sensitive = TicketBotService.containsSensitiveInformation(text);
    final safeText = sensitive ? '[Sensitive information removed]' : text;
    final response = sensitive ? null : _service.respond(text);
    setState(() {
      _conversation
        ..add(_ConversationEntry(text: safeText, isUser: true))
        ..add(
          _ConversationEntry(
            text: sensitive
                ? 'For your security, do not share card numbers, CVV, passwords, bank details, or verification codes here. I have not retained that information.'
                : response!.text,
            isUser: false,
          ),
        );
      _latestAnalysis = response;
      _latestQuestion = safeText;
      _sensitiveInputWasRedacted = sensitive;
    });
    if (prompt == null) _messageController.clear();
    _scrollChatToBottom();
  }

  void _resetConversation() {
    _service.reset();
    setState(() {
      _conversation
        ..clear()
        ..add(
          const _ConversationEntry(
            text:
                "Hello! I'm TicketBot, your ticket booking support assistant.\n\nI can help with booking, cancellations, refunds, payments, ticket details, and rescheduling. What can I help you with today?",
            isUser: false,
          ),
        );
      _latestAnalysis = null;
      _latestQuestion = '';
      _sensitiveInputWasRedacted = false;
    });
  }

  void _scrollChatToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatScrollController.hasClients) {
        _chatScrollController.animateTo(
          _chatScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 1040;
            final content = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(wide),
                const SizedBox(height: 20),
                if (wide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildChatPanel()),
                      const SizedBox(width: 18),
                      SizedBox(width: 350, child: _buildSidebar()),
                    ],
                  )
                else ...[
                  _buildChatPanel(),
                  const SizedBox(height: 16),
                  _buildSidebar(),
                ],
                const SizedBox(height: 18),
                _buildAnalysisCard(),
                const SizedBox(height: 18),
                _buildHowItWorks(),
                const SizedBox(height: 28),
              ],
            );
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: wide ? 32 : 16,
                vertical: 20,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1500),
                  child: content,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(bool wide) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _navy,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.confirmation_number_outlined,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TicketBot',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: _navy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                wide
                    ? 'NLP-Based Ticket Booking & Refund Assistant'
                    : 'Ticket Booking & Refund Assistant',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: _muted),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF5EF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: _green, size: 8),
              SizedBox(width: 6),
              Text(
                'Online',
                style: TextStyle(
                  color: _green,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (wide) const SizedBox(width: 12),
        if (wide)
          OutlinedButton.icon(
            onPressed: _resetConversation,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('New conversation'),
            style: OutlinedButton.styleFrom(foregroundColor: _ink),
          ),
      ],
    );
  }

  Widget _buildChatPanel() {
    final wide = MediaQuery.sizeOf(context).width >= 1040;
    return _Panel(
      child: SizedBox(
        height: wide ? 700 : 650,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Support chat',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Answers grounded in the TicketBot FAQ',
                        style: TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (!wide)
                  IconButton(
                    tooltip: 'New conversation',
                    onPressed: _resetConversation,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFFAFCFE),
                  border: Border.all(color: _line),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  controller: _chatScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _conversation.length,
                  itemBuilder: (context, index) =>
                      _buildMessage(_conversation[index]),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (_conversation.length == 1) ...[
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Quick actions',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 7),
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:
                      const <String, String>{
                            'Book a ticket': 'How do I book a ticket?',
                            'Cancel ticket': 'I want to cancel my ticket.',
                            'Refund help': 'How much refund will I get?',
                            'Payment issue': 'My payment failed.',
                            'Ticket details': 'Where can I download my ticket?',
                            'Reschedule': 'Can I reschedule my booking?',
                          }.entries
                          .map(
                            (action) => Padding(
                              padding: const EdgeInsets.only(right: 7),
                              child: ActionChip(
                                label: Text(action.key),
                                onPressed: () => _sendMessage(action.value),
                                backgroundColor: _blueTint,
                                side: BorderSide.none,
                                labelStyle: const TextStyle(
                                  color: _blue,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
              const SizedBox(height: 8),
            ],
            _buildComposer(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(_ConversationEntry entry) {
    return Align(
      alignment: entry.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.72,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: entry.isUser ? _blue : Colors.white,
          border: entry.isUser ? null : Border.all(color: _line),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SelectableText(
          entry.text,
          style: TextStyle(
            color: entry.isUser ? Colors.white : _ink,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _messageController,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _sendMessage(),
            maxLines: 1,
            decoration: InputDecoration(
              hintText: 'Ask about a booking, ticket, payment, or refund',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _line),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: _blue, width: 1.5),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 48,
          width: 48,
          child: IconButton.filled(
            tooltip: 'Send message',
            onPressed: _sendMessage,
            icon: const Icon(Icons.send_rounded, size: 19),
            style: IconButton.styleFrom(
              backgroundColor: _blue,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return _buildFaqPanel();
  }

  Widget _buildAnalysisCard() {
    final analysis = _latestAnalysis;
    final entities = analysis?.entities.entries
        .map((entry) => '${entry.key} = ${entry.value}')
        .join('\n');
    return _Panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeading(
            icon: Icons.analytics_outlined,
            title: 'NLP analysis',
          ),
          const SizedBox(height: 12),
          if (analysis == null)
            Text(
              _sensitiveInputWasRedacted
                  ? 'Sensitive input was removed and was not analyzed. Send a support question to inspect its NLP results.'
                  : 'Send a question to see its detected intent, entities, keywords, FAQ match, and similarity score.',
              style: const TextStyle(color: _muted, fontSize: 12, height: 1.5),
            )
          else ...[
            _AnalysisRow(label: 'Input', value: _latestQuestion),
            _AnalysisRow(label: 'Intent', value: analysis.intent),
            _AnalysisRow(
              label: 'Category',
              value: analysis.category.isEmpty
                  ? 'Not classified'
                  : analysis.category,
            ),
            _AnalysisRow(
              label: 'Entities',
              value: entities == null || entities.isEmpty
                  ? 'None detected'
                  : entities,
            ),
            _AnalysisRow(
              label: 'Keywords',
              value: analysis.keywords.join(', ').ifEmpty('None'),
            ),
            _AnalysisRow(
              label: 'FAQ match',
              value: analysis.faqId ?? 'No match',
            ),
            _AnalysisRow(
              label: 'Similarity',
              value: '${(analysis.similarity * 100).round()}%',
            ),
            if (analysis.ruleEngine != null)
              _AnalysisRow(label: 'Rule engine', value: analysis.ruleEngine!),
          ],
        ],
      ),
    );
  }

  Widget _buildFaqPanel() {
    return _Panel(
      padding: const EdgeInsets.fromLTRB(14, 15, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _PanelHeading(
            icon: Icons.help_outline_rounded,
            title: 'Frequently asked questions',
          ),
          const SizedBox(height: 7),
          for (final category in TicketBotService.categories)
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              childrenPadding: const EdgeInsets.only(left: 4, bottom: 6),
              dense: true,
              visualDensity: VisualDensity.compact,
              title: Text(
                category,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                for (final faq in TicketBotService.faqs.where(
                  (item) => item.category == category,
                ))
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => _sendMessage(faq.question),
                      style: TextButton.styleFrom(
                        foregroundColor: _blue,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                          horizontal: 7,
                        ),
                        textStyle: const TextStyle(fontSize: 11, height: 1.3),
                      ),
                      child: Text(faq.question, textAlign: TextAlign.left),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    const stages = [
      'User input',
      'Text preprocessing',
      'Intent detection',
      'Entity extraction',
      'FAQ retrieval',
      'Similarity match',
      'Rule engine',
      'Response generation',
    ];
    return _Panel(
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(top: 4, bottom: 8),
        title: const Text(
          'How TicketBot Works',
          style: TextStyle(
            color: _ink,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: const Text(
          'A deterministic, retrieval-based NLP pipeline',
          style: TextStyle(color: _muted, fontSize: 12),
        ),
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < stages.length; i++)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: i == 6 ? const Color(0xFFEAF5EF) : _blueTint,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${i + 1}. ${stages[i]}',
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Example: “Can I cancel my ₹1,500 ticket?” → intent: ticket_cancellation; entity: ticket_amount = ₹1,500. With 10 hours remaining, the demo rule applies a 40% fee (₹600) and returns an estimated refund of ₹900.',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 7),
          const Text(
            'Demo Cancellation Policy: over 48h = 10%; 24–48h = 20%; 6–24h = 40%; 2–6h = 60%; under 2h = 100%. Demonstration rules only, not a real ticketing company policy.',
            style: TextStyle(color: _muted, fontSize: 11, height: 1.45),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _chatScrollController.dispose();
    super.dispose();
  }
}

class _ConversationEntry {
  const _ConversationEntry({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _line),
      boxShadow: const [
        BoxShadow(
          color: Color(0x080E2A43),
          blurRadius: 14,
          offset: Offset(0, 3),
        ),
      ],
    ),
    child: Material(type: MaterialType.transparency, child: child),
  );
}

class _PanelHeading extends StatelessWidget {
  const _PanelHeading({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: _blue, size: 18),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    ],
  );
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: _muted,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: _ink, fontSize: 12, height: 1.35),
        ),
      ],
    ),
  );
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
