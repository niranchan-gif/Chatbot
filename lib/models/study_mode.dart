enum StudyModeType { explain, quiz, coding, simplify, summarize }

class StudyMode {
  final StudyModeType type;
  final String label;
  final String emoji;
  final String description;
  final String hint;
  final int colorValue;
  final List<String> quickPrompts;

  const StudyMode({
    required this.type,
    required this.label,
    required this.emoji,
    required this.description,
    required this.hint,
    required this.colorValue,
    required this.quickPrompts,
  });

  String get id => type.name;

  static const List<StudyMode> all = [
    StudyMode(
      type: StudyModeType.explain,
      label: 'Explain',
      emoji: '📖',
      description: 'Deep explanations of any concept',
      hint: 'Try: "Explain binary search"',
      colorValue: 0xFFF59E0B,
      quickPrompts: [
        'Explain binary search',
        'Explain OSI model',
        'Explain DBMS normalization',
        'Explain recursion',
      ],
    ),
    StudyMode(
      type: StudyModeType.quiz,
      label: 'Quiz Me',
      emoji: '🧠',
      description: 'Test your knowledge interactively',
      hint: 'Try: "Quiz me on data structures"',
      colorValue: 0xFF8B5CF6,
      quickPrompts: [
        'Quiz me on binary search',
        'Quiz me on sorting algorithms',
        'Quiz me on networking',
        'Quiz me on SQL',
      ],
    ),
    StudyMode(
      type: StudyModeType.coding,
      label: 'Coding Help',
      emoji: '💻',
      description: 'Code examples and walkthroughs',
      hint: 'Try: "Show binary search in Python"',
      colorValue: 0xFF3B82F6,
      quickPrompts: [
        'Show binary search in Python',
        'Write a quicksort algorithm',
        'How does recursion work in code?',
        'Show me a linked list',
      ],
    ),
    StudyMode(
      type: StudyModeType.simplify,
      label: 'Simplify',
      emoji: '🔄',
      description: 'Complex topics made simple',
      hint: 'Try: "Simplify Big O notation"',
      colorValue: 0xFF10B981,
      quickPrompts: [
        'Simplify Big O notation',
        'Simplify database joins',
        'Simplify recursion',
        'Simplify TCP/IP',
      ],
    ),
    StudyMode(
      type: StudyModeType.summarize,
      label: 'Summarize',
      emoji: '📝',
      description: 'Quick summaries of any topic',
      hint: 'Try: "Summarize sorting algorithms"',
      colorValue: 0xFFF43F5E,
      quickPrompts: [
        'Summarize sorting algorithms',
        'Summarize the OSI model',
        'Summarize DBMS concepts',
        'Summarize graph algorithms',
      ],
    ),
  ];

  static StudyMode fromLabel(String label) {
    return all.firstWhere((m) => m.label == label, orElse: () => all.first);
  }
}
