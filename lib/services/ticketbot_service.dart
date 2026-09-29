import 'dart:math' as math;

import 'package:intl/intl.dart';

class TicketFaq {
  const TicketFaq({
    required this.id,
    required this.category,
    required this.intent,
    required this.question,
    required this.alternatives,
    required this.keywords,
    required this.answer,
  });

  final String id;
  final String category;
  final String intent;
  final String question;
  final List<String> alternatives;
  final List<String> keywords;
  final String answer;
}

class RefundResult {
  const RefundResult({
    required this.ticketAmount,
    required this.remainingHours,
    required this.cancellationPercent,
    required this.cancellationFee,
    required this.refundAmount,
    required this.policyRange,
  });

  final double ticketAmount;
  final double remainingHours;
  final int cancellationPercent;
  final double cancellationFee;
  final double refundAmount;
  final String policyRange;
}

class TicketBotResponse {
  const TicketBotResponse({
    required this.text,
    required this.intent,
    required this.category,
    required this.keywords,
    required this.entities,
    required this.similarity,
    this.faqId,
    this.ruleEngine,
  });

  final String text;
  final String intent;
  final String category;
  final List<String> keywords;
  final Map<String, String> entities;
  final double similarity;
  final String? faqId;
  final String? ruleEngine;
}

class TicketBotService {
  TicketBotService({this.confidenceThreshold = 0.12});

  final double confidenceThreshold;

  static const List<TicketFaq> faqs = [
    TicketFaq(
      id: 'BOOK001',
      category: 'Booking',
      intent: 'ticket_booking',
      question: 'How do I book a ticket?',
      alternatives: [
        'How can I reserve a ticket?',
        'How do I make a booking?',
        'I want to reserve a ticket',
        'How can I book a ticket?',
        'Can you tell me how to make a booking?',
      ],
      keywords: ['book', 'booking', 'reserve', 'ticket', 'procedure'],
      answer:
          'Choose an event, select a date and available seat, enter the required attendee details, then complete payment. Your ticket is generated after payment is confirmed.',
    ),
    TicketFaq(
      id: 'BOOK002',
      category: 'Booking',
      intent: 'ticket_booking',
      question: 'Can I book multiple tickets?',
      alternatives: [
        'Can I buy tickets for my group?',
        'Book more than one ticket',
      ],
      keywords: ['multiple', 'several', 'group', 'tickets', 'quantity'],
      answer:
          'Yes. Select the number of available tickets before choosing seats. The maximum per booking depends on the event.',
    ),
    TicketFaq(
      id: 'BOOK003',
      category: 'Booking',
      intent: 'seat_selection',
      question: 'Can I select my seat?',
      alternatives: [
        'How do I choose a seat?',
        'Can I change my selected seat before paying?',
        'I want to reserve a seat',
      ],
      keywords: ['seat', 'select', 'choose', 'reserve', 'seating'],
      answer:
          'Available seats appear on the event seating map. Choose an open seat before payment; a seat is confirmed only after your booking is complete.',
    ),
    TicketFaq(
      id: 'BOOK004',
      category: 'Booking',
      intent: 'ticket_booking',
      question: 'Can I book a ticket for another person?',
      alternatives: [
        'Can I buy a ticket for someone else?',
        'Booking in another person’s name',
      ],
      keywords: ['another person', 'someone else', 'guest', 'name'],
      answer:
          'You can book for another attendee. Enter the attendee details requested during checkout and share the generated ticket with them.',
    ),
    TicketFaq(
      id: 'BOOK005',
      category: 'Booking',
      intent: 'ticket_booking',
      question: 'What information is required for booking?',
      alternatives: [
        'What details do I need to book?',
        'What information is needed at checkout?',
      ],
      keywords: ['information', 'details', 'booking', 'checkout', 'required'],
      answer:
          'Have the attendee name and a reachable email address or phone number ready. The exact details can vary by event.',
    ),
    TicketFaq(
      id: 'PAY001',
      category: 'Payment',
      intent: 'payment_methods',
      question: 'What payment methods are supported?',
      alternatives: [
        'How can I pay?',
        'Is online payment required?',
        'Which payment options can I use?',
      ],
      keywords: ['payment', 'pay', 'card', 'upi', 'methods', 'online'],
      answer:
          'Available payment methods are shown at checkout and vary by event and region. This prototype does not collect or process real payment details.',
    ),
    TicketFaq(
      id: 'PAY002',
      category: 'Payment',
      intent: 'payment_failed',
      question: 'My payment failed. What should I do?',
      alternatives: [
        'Can I retry a failed payment?',
        'Payment timed out',
        'My payment did not go through',
      ],
      keywords: [
        'payment',
        'failed',
        'failure',
        'retry',
        'timeout',
        'declined',
      ],
      answer:
          'Check your booking status before trying again. If no booking was created, wait for the payment provider to release any temporary hold, then retry using an available method.',
    ),
    TicketFaq(
      id: 'PAY003',
      category: 'Payment',
      intent: 'payment_pending',
      question: 'My payment is pending. What happens next?',
      alternatives: [
        'Payment is still processing',
        'My payment status is pending',
      ],
      keywords: ['pending', 'processing', 'payment', 'status'],
      answer:
          'Allow the payment provider a few minutes to update the status. Check your bookings before retrying so you do not create a duplicate payment.',
    ),
    TicketFaq(
      id: 'PAY004',
      category: 'Payment',
      intent: 'payment_duplicate',
      question: 'I was charged twice.',
      alternatives: [
        'I made a duplicate payment',
        'I see two charges for one booking',
      ],
      keywords: ['charged', 'twice', 'duplicate', 'double', 'payment'],
      answer:
          'Check whether both charges completed and whether you have duplicate bookings. Contact the payment provider or event support with the transaction references; never share card security codes.',
    ),
    TicketFaq(
      id: 'PAY005',
      category: 'Payment',
      intent: 'ticket_confirmation',
      question: 'Money was deducted but my ticket was not generated.',
      alternatives: [
        'I paid but did not receive a ticket',
        'Payment succeeded but there is no confirmation',
      ],
      keywords: [
        'deducted',
        'charged',
        'paid',
        'ticket',
        'confirmation',
        'missing',
      ],
      answer:
          'Check your booking list and email first; confirmation can take a few minutes. If no ticket appears, contact event support with your booking attempt time and payment reference. Do not share full card or bank credentials.',
    ),
    TicketFaq(
      id: 'TICK001',
      category: 'Ticket',
      intent: 'ticket_download',
      question: 'Where can I find or download my ticket?',
      alternatives: [
        'How do I download my ticket?',
        'I did not receive my ticket',
        'Where is my booking ID?',
      ],
      keywords: [
        'ticket',
        'download',
        'find',
        'email',
        'booking id',
        'confirmation',
      ],
      answer:
          'Open your account’s bookings and select the confirmed event to view or download its ticket. Also check the email used at checkout, including the spam folder.',
    ),
    TicketFaq(
      id: 'TICK002',
      category: 'Ticket',
      intent: 'ticket_download',
      question: 'Can I show my ticket on my phone or print it?',
      alternatives: [
        'Is a mobile ticket accepted?',
        'Do I need to print my ticket?',
      ],
      keywords: ['phone', 'mobile', 'print', 'paper', 'ticket'],
      answer:
          'The event entry instructions determine whether a phone display or printed ticket is accepted. Keep the ticket barcode or QR code visible and bring valid ID if requested.',
    ),
    TicketFaq(
      id: 'TICK003',
      category: 'Ticket',
      intent: 'ticket_confirmation',
      question: 'How can I check my booking?',
      alternatives: ['Where are my bookings?', 'How do I confirm my booking?'],
      keywords: ['check', 'booking', 'status', 'confirm', 'order'],
      answer:
          'Sign in with the email or phone used at checkout and open your bookings. A confirmed booking should show its event details and booking ID.',
    ),
    TicketFaq(
      id: 'CANC001',
      category: 'Cancellation',
      intent: 'ticket_cancellation',
      question: 'Can I cancel my ticket?',
      alternatives: [
        'How do I cancel a ticket?',
        'Can I cancel after booking?',
        'I want to cancel my booking',
      ],
      keywords: ['cancel', 'cancellation', 'ticket', 'booking', 'undo'],
      answer:
          'Cancellation eligibility and charges depend on the event and time remaining. For this prototype, the Demo Cancellation Policy estimates a charge from 10% to 100%. Ask me to calculate a refund and provide the ticket amount and hours until the event.',
    ),
    TicketFaq(
      id: 'CANC002',
      category: 'Cancellation',
      intent: 'ticket_cancellation',
      question: 'Is there a cancellation fee?',
      alternatives: [
        'What happens if I cancel?',
        'Can I cancel shortly before the event?',
      ],
      keywords: ['cancellation', 'fee', 'charge', 'before', 'event'],
      answer:
          'This demo uses a time-based cancellation fee: 10% over 48 hours, 20% from 24 to 48 hours, 40% from 6 to 24 hours, 60% from 2 to 6 hours, and 100% within 2 hours. This is a project demonstration rule, not a real company policy.',
    ),
    TicketFaq(
      id: 'REF001',
      category: 'Refund',
      intent: 'refund_calculation',
      question: 'How much refund will I get?',
      alternatives: [
        'How much will I get back if I cancel?',
        'Calculate my refund',
        'Is the cancellation charge deducted?',
      ],
      keywords: ['refund', 'calculate', 'amount', 'cancel', 'fee', 'charge'],
      answer:
          'I can calculate an estimate using the demo cancellation policy. Tell me your ticket amount and approximately how many hours remain before the event.',
    ),
    TicketFaq(
      id: 'REF002',
      category: 'Refund',
      intent: 'refund_timing',
      question: 'How long does a refund take?',
      alternatives: [
        'When will I receive my refund?',
        'Where will the refund be credited?',
      ],
      keywords: ['refund', 'when', 'long', 'credited', 'processing', 'time'],
      answer:
          'Refund timelines depend on the payment method and provider. Once a cancellation is approved, check the original payment method and the provider’s transaction status for the latest estimate.',
    ),
    TicketFaq(
      id: 'REF003',
      category: 'Refund',
      intent: 'refund_status',
      question: 'How can I check my refund status?',
      alternatives: [
        'Why did I receive a partial refund?',
        'Where is my refund?',
      ],
      keywords: ['refund', 'status', 'partial', 'check', 'track'],
      answer:
          'Review the cancellation details in your booking history and check the original payment method. A partial amount may reflect the cancellation charge shown when the cancellation was confirmed.',
    ),
    TicketFaq(
      id: 'RES001',
      category: 'Rescheduling',
      intent: 'rescheduling',
      question: 'Can I change my ticket date or show?',
      alternatives: [
        'Can I change my show?',
        'Can I reschedule my booking?',
        'Is there a rescheduling fee?',
      ],
      keywords: ['change', 'date', 'show', 'reschedule', 'rescheduling', 'fee'],
      answer:
          'Date and show changes depend on event availability and its terms. Open the booking details to check for a change option; if it is unavailable, contact event support before cancelling.',
    ),
    TicketFaq(
      id: 'RES002',
      category: 'Rescheduling',
      intent: 'rescheduling',
      question: 'Can I change my seat?',
      alternatives: [
        'I selected the wrong seat',
        'Can I move to another seat?',
      ],
      keywords: ['change', 'seat', 'move', 'selected'],
      answer:
          'Before payment, return to the seating map and choose another available seat. After confirmation, seat changes depend on the event’s terms and availability.',
    ),
    TicketFaq(
      id: 'EVENT001',
      category: 'Event',
      intent: 'event_information',
      question: 'What time does the show start and when should I arrive?',
      alternatives: [
        'Can I enter after the show starts?',
        'How early should I arrive?',
      ],
      keywords: ['show', 'start', 'time', 'arrive', 'late', 'entry'],
      answer:
          'Check the event listing and ticket for the start time and venue entry guidance. Arrive early enough for security and check-in; late-entry rules are set by the event organizer.',
    ),
    TicketFaq(
      id: 'EVENT002',
      category: 'Event',
      intent: 'event_information',
      question: 'What happens if an event is cancelled?',
      alternatives: [
        'Where can I see event details?',
        'How do I find event information?',
      ],
      keywords: ['event', 'cancelled', 'details', 'organizer', 'information'],
      answer:
          'The organizer’s event notice explains the next steps. Check the event page and your registered email for rescheduling or refund instructions.',
    ),
    TicketFaq(
      id: 'ACC001',
      category: 'Account',
      intent: 'account_support',
      question: 'How do I create an account or update my profile?',
      alternatives: [
        'How do I change my phone number?',
        'I forgot my password',
      ],
      keywords: ['account', 'profile', 'phone', 'password', 'create', 'update'],
      answer:
          'Use the account sign-in or registration page to manage your profile and recovery options. For security, never share your password or one-time verification code in chat.',
    ),
  ];

  static const List<String> categories = [
    'Booking',
    'Payment',
    'Cancellation',
    'Refund',
    'Ticket',
    'Rescheduling',
    'Event',
    'Account',
  ];

  static const List<String> demoQuestions = [
    'How do I book a ticket?',
    'Can I select my seat?',
    'Can I cancel my ticket?',
    'How much refund will I get?',
    'My payment failed.',
    'My money was deducted but I did not get a ticket.',
    'Where can I download my ticket?',
    'Can I change my show?',
    'How long does a refund take?',
    'Can I reschedule my booking?',
  ];

  static const Set<String> _stopWords = {
    'a',
    'about',
    'after',
    'am',
    'an',
    'and',
    'are',
    'as',
    'at',
    'be',
    'before',
    'can',
    'do',
    'for',
    'from',
    'get',
    'how',
    'i',
    'if',
    'in',
    'is',
    'it',
    'me',
    'my',
    'of',
    'on',
    'or',
    'the',
    'this',
    'to',
    'was',
    'tell',
    'what',
    'when',
    'where',
    'which',
    'will',
    'with',
    'would',
    'you',
  };

  static const double maxTicketAmount = 1000000000;
  static const double maxRemainingHours = 24 * 365 * 10;
  static bool containsSensitiveInformation(String text) {
    final credentialValue = RegExp(
      r'\b(?:password|passcode)\s*(?:is|:|=)\s*\S+|\b(?:cvv|cvc|security code|otp|one[- ]time code|verification code)\s*(?:is|:|=)?\s*\d{3,8}\b|\b(?:card|bank account|account|routing) number\s*(?:is|:|=)?\s*(?:\d[ -]?){6,}\d',
      caseSensitive: false,
    );
    final cardNumber = RegExp(r'(?<!\d)(?:\d[ -]?){13,18}\d(?!\d)');
    return credentialValue.hasMatch(text) || cardNumber.hasMatch(text);
  }

  double? ticketAmount;
  double? remainingHours;
  String? awaitingField;
  String currentIntent = 'unknown';
  String currentCategory = '';
  String? lastMatchedFaq;

  void reset() {
    ticketAmount = null;
    remainingHours = null;
    awaitingField = null;
    currentIntent = 'unknown';
    currentCategory = '';
    lastMatchedFaq = null;
  }

  TicketBotResponse respond(String input) {
    final text = input.trim();
    final tokens = preprocess(text);
    final keywords = tokens.toList()..sort();
    final entities = extractEntities(text);

    if (text.isEmpty) {
      return _response(
        'Please enter a question about booking, tickets, payment, cancellation, refunds, or events.',
        intent: 'unknown',
        keywords: keywords,
        entities: entities,
      );
    }

    if (awaitingField != null) {
      return _continueRefundFlow(text, keywords, entities);
    }

    final faqMatch = _bestMatch(tokens);
    final hasAmount = entities.containsKey('ticket_amount');
    final hasTime = entities.containsKey('remaining_hours');
    final cancellationRequest = _isCancellationRequest(text);
    final refundRequest = _isRefundRequest(text);
    final isInformationalRefundFaq =
        faqMatch.faq?.intent == 'refund_timing' ||
        faqMatch.faq?.intent == 'refund_status';
    final refundIntent =
        (cancellationRequest && (hasAmount || hasTime)) ||
        (cancellationRequest && _isExplicitCancellation(text)) ||
        (refundRequest && !isInformationalRefundFaq) ||
        (hasAmount && hasTime);

    if (refundIntent) {
      currentIntent = cancellationRequest
          ? 'ticket_cancellation'
          : 'refund_calculation';
      currentCategory = cancellationRequest ? 'Cancellation' : 'Refund';
      lastMatchedFaq = faqMatch.faq?.id ?? 'REF001';
      final extractedAmount = _parseAmount(text, entities);
      final extractedHours = _parseHours(text, entities);
      if (extractedAmount != null && extractedAmount > maxTicketAmount) {
        awaitingField = 'ticketAmount';
        return _response(
          'That ticket amount is above the supported demo limit. Please provide an amount up to ₹1,000,000,000.',
          intent: currentIntent,
          category: currentCategory,
          keywords: keywords,
          entities: entities,
          faqId: lastMatchedFaq,
          ruleEngine: 'Awaiting valid ticket amount',
        );
      }
      if (extractedHours != null &&
          (extractedHours < 0 || extractedHours > maxRemainingHours)) {
        ticketAmount = extractedAmount;
        awaitingField = 'remainingHours';
        return _response(
          'Please provide a non-negative time remaining up to 87,600 hours.',
          intent: currentIntent,
          category: currentCategory,
          keywords: keywords,
          entities: entities,
          faqId: lastMatchedFaq,
          ruleEngine: 'Awaiting valid remaining hours',
        );
      }
      ticketAmount = extractedAmount;
      remainingHours = extractedHours;
      return _refundPromptOrResult(keywords, entities);
    }

    if (faqMatch.faq == null || faqMatch.score < confidenceThreshold) {
      currentIntent = 'unknown';
      currentCategory = '';
      return _response(
        'I’m not confident I found the right answer. Try asking about booking, cancellation, refunds, payment, tickets, rescheduling, event information, or account support.',
        intent: 'unknown',
        keywords: keywords,
        entities: entities,
        similarity: faqMatch.score,
      );
    }

    final faq = faqMatch.faq!;
    currentIntent = faq.intent;
    currentCategory = faq.category;
    lastMatchedFaq = faq.id;
    return _response(
      faq.answer,
      intent: faq.intent,
      category: faq.category,
      keywords: keywords,
      entities: entities,
      similarity: faqMatch.score,
      faqId: faq.id,
    );
  }

  TicketBotResponse _continueRefundFlow(
    String text,
    List<String> keywords,
    Map<String, String> entities,
  ) {
    if (awaitingField == 'ticketAmount') {
      final amount = _parseAmount(text, entities, allowBareNumber: true);
      if (amount == null || amount < 0 || amount > maxTicketAmount) {
        return _response(
          'Please enter a valid non-negative ticket amount up to ₹1,000,000,000. For example: ₹1,500.',
          intent: currentIntent,
          category: currentCategory,
          keywords: keywords,
          entities: entities,
          faqId: lastMatchedFaq,
        );
      }
      ticketAmount = amount;
      entities['ticket_amount'] = formatCurrency(amount);
      awaitingField = 'remainingHours';
      return _response(
        'Got it. How many hours are left before the event?',
        intent: currentIntent,
        category: currentCategory,
        keywords: keywords,
        entities: entities,
        faqId: lastMatchedFaq,
      );
    }

    final hours = _parseHours(text, entities, allowBareNumber: true);
    if (hours == null || hours < 0 || hours > maxRemainingHours) {
      return _response(
        'Please enter a valid time remaining in hours (0 to 87,600). For example: 10 hours.',
        intent: currentIntent,
        category: currentCategory,
        keywords: keywords,
        entities: entities,
        faqId: lastMatchedFaq,
      );
    }
    remainingHours = hours;
    entities['remaining_hours'] = '${_formatNumber(hours)} hours';
    awaitingField = null;
    return _refundPromptOrResult(keywords, entities);
  }

  TicketBotResponse _refundPromptOrResult(
    List<String> keywords,
    Map<String, String> entities,
  ) {
    if (ticketAmount == null) {
      awaitingField = 'ticketAmount';
      return _response(
        'Sure. I can calculate your estimated refund. What was the ticket amount?',
        intent: currentIntent,
        category: currentCategory,
        keywords: keywords,
        entities: entities,
        faqId: lastMatchedFaq,
        ruleEngine: 'Awaiting ticket amount',
      );
    }
    if (remainingHours == null) {
      awaitingField = 'remainingHours';
      return _response(
        'You have provided the ticket amount as ${formatCurrency(ticketAmount!)}. I still need the approximate time remaining before the event to calculate the cancellation charge.',
        intent: currentIntent,
        category: currentCategory,
        keywords: keywords,
        entities: entities,
        faqId: lastMatchedFaq,
        ruleEngine: 'Awaiting remaining hours',
      );
    }

    final result = calculateRefund(ticketAmount!, remainingHours!);
    entities['ticket_amount'] = formatCurrency(result.ticketAmount);
    entities['remaining_hours'] =
        '${_formatNumber(result.remainingHours)} hours';
    awaitingField = null;
    return _response(
      'Here is your refund estimate:\n\n'
      'Ticket amount: ${formatCurrency(result.ticketAmount)}\n'
      'Time remaining: ${_formatNumber(result.remainingHours)} hours\n'
      'Cancellation charge: ${result.cancellationPercent}%\n'
      'Cancellation amount: ${formatCurrency(result.cancellationFee)}\n\n'
      'Estimated refund: ${formatCurrency(result.refundAmount)}\n\n'
      'This calculation uses the TicketBot demo cancellation policy.',
      intent: currentIntent,
      category: currentCategory,
      keywords: keywords,
      entities: entities,
      similarity: 1,
      faqId: lastMatchedFaq,
      ruleEngine: result.policyRange,
    );
  }

  TicketBotResponse _response(
    String text, {
    required String intent,
    required List<String> keywords,
    required Map<String, String> entities,
    String category = '',
    double similarity = 0,
    String? faqId,
    String? ruleEngine,
  }) => TicketBotResponse(
    text: text,
    intent: intent,
    category: category,
    keywords: keywords,
    entities: Map.unmodifiable(entities),
    similarity: similarity.clamp(0, 1),
    faqId: faqId,
    ruleEngine: ruleEngine,
  );

  static RefundResult calculateRefund(
    double ticketAmount,
    double remainingHours,
  ) {
    if (!ticketAmount.isFinite ||
        !remainingHours.isFinite ||
        ticketAmount < 0 ||
        remainingHours < 0 ||
        ticketAmount > maxTicketAmount ||
        remainingHours > maxRemainingHours) {
      throw ArgumentError(
        'Amount and remaining hours are outside valid limits.',
      );
    }

    final (percent, range) = switch (remainingHours) {
      > 48 => (10, 'More than 48 hours'),
      >= 24 => (20, '24–48 hours'),
      >= 6 => (40, '6–24 hours'),
      >= 2 => (60, '2–6 hours'),
      _ => (100, 'Less than 2 hours'),
    };
    final fee = _roundCurrency(ticketAmount * percent / 100);
    return RefundResult(
      ticketAmount: ticketAmount,
      remainingHours: remainingHours,
      cancellationPercent: percent,
      cancellationFee: fee,
      refundAmount: _roundCurrency(ticketAmount - fee),
      policyRange: range,
    );
  }

  static String formatCurrency(double amount) {
    if (!amount.isFinite) return '₹0';
    final digits = amount == amount.truncateToDouble() ? 0 : 2;
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: digits,
    ).format(amount);
  }

  static Map<String, String> extractEntities(String text) {
    final entities = <String, String>{};
    final amount = _parseAmount(text, entities);
    if (amount != null) {
      entities['ticket_amount'] = formatCurrency(amount);
    }
    final hours = _parseHours(text, entities);
    if (hours != null) {
      entities['remaining_hours'] = '${_formatNumber(hours)} hours';
    }

    final date = RegExp(
      r'\b\d{4}-\d{1,2}-\d{1,2}\b|\b\d{1,2}[/-]\d{1,2}[/-]\d{2,4}\b',
    ).firstMatch(text);
    if (date != null) {
      entities['date'] = date.group(0)!;
    }
    final time = RegExp(
      r'\b\d{1,2}(?::\d{2})\s*(?:am|pm)\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (time != null) {
      entities['time'] = time.group(0)!;
    }
    if (_isCancellationRequest(text)) {
      entities['cancellation_request'] = 'true';
    }
    return entities;
  }

  static List<String> preprocess(String text) {
    final normalized = text.toLowerCase().replaceAll('’', "'");
    final rawTokens = RegExp(r"[a-z]+|\d+(?:\.\d+)?")
        .allMatches(normalized)
        .map((match) => _stem(match.group(0)!))
        .where((token) => token.length > 1 && !_stopWords.contains(token));
    return rawTokens.toSet().toList();
  }

  _FaqMatch _bestMatch(List<String> queryTokens) {
    if (queryTokens.isEmpty) return const _FaqMatch(null, 0);
    final documents = faqs.map(_documentTokens).toList();
    final documentFrequency = <String, int>{};
    for (final document in documents) {
      for (final token in document.toSet()) {
        documentFrequency.update(
          token,
          (count) => count + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final queryVector = _tfIdf(queryTokens, documentFrequency, faqs.length);
    if (_isGeneralBookingQuestion(queryTokens)) {
      final faq = faqs.firstWhere((item) => item.id == 'BOOK001');
      final index = faqs.indexOf(faq);
      final vector = _tfIdf(documents[index], documentFrequency, faqs.length);
      return _FaqMatch(faq, _cosine(queryVector, vector));
    }

    TicketFaq? bestFaq;
    var bestScore = 0.0;
    for (var index = 0; index < faqs.length; index++) {
      final documentVector = _tfIdf(
        documents[index],
        documentFrequency,
        faqs.length,
      );
      final score = _cosine(queryVector, documentVector);
      if (score > bestScore) {
        bestFaq = faqs[index];
        bestScore = score;
      }
    }
    return _FaqMatch(bestFaq, bestScore);
  }

  static bool _isGeneralBookingQuestion(List<String> tokens) {
    final words = tokens.toSet();
    final hasBookingVerb = words.contains('book') || words.contains('reserve');
    const specificTerms = {
      'cancel',
      'cancellation',
      'refund',
      'multiple',
      'several',
      'group',
      'quantity',
      'seat',
      'select',
      'choose',
      'another',
      'person',
      'someone',
      'detail',
      'information',
      'required',
      'checkout',
      'status',
      'confirm',
      'check',
      'change',
      'date',
      'show',
    };
    return hasBookingVerb && words.intersection(specificTerms).isEmpty;
  }

  static List<String> _documentTokens(TicketFaq faq) => preprocess(
    [faq.question, ...faq.alternatives, ...faq.keywords].join(' '),
  );

  static Map<String, double> _tfIdf(
    List<String> tokens,
    Map<String, int> documentFrequency,
    int documentCount,
  ) {
    final counts = <String, int>{};
    for (final token in tokens) {
      counts.update(token, (count) => count + 1, ifAbsent: () => 1);
    }
    final vector = <String, double>{};
    for (final entry in counts.entries) {
      final frequency = documentFrequency[entry.key] ?? 0;
      final idf = math.log((documentCount + 1) / (frequency + 1)) + 1;
      vector[entry.key] = entry.value * idf;
    }
    return vector;
  }

  static double _cosine(Map<String, double> left, Map<String, double> right) {
    var dot = 0.0;
    var leftNorm = 0.0;
    var rightNorm = 0.0;
    for (final value in left.values) {
      leftNorm += value * value;
    }
    for (final entry in right.entries) {
      rightNorm += entry.value * entry.value;
      dot += (left[entry.key] ?? 0) * entry.value;
    }
    if (leftNorm == 0 || rightNorm == 0) return 0;
    return dot / (math.sqrt(leftNorm) * math.sqrt(rightNorm));
  }

  static String _stem(String token) {
    if (token.length > 5 && token.endsWith('ing')) {
      return token.substring(0, token.length - 3);
    }
    if (token.length > 4 && token.endsWith('ies')) {
      return '${token.substring(0, token.length - 3)}y';
    }
    if (token.length > 4 && token.endsWith('es')) {
      return token.substring(0, token.length - 2);
    }
    if (token.length > 3 && token.endsWith('s')) {
      return token.substring(0, token.length - 1);
    }
    if (token.length > 4 && token.endsWith('ed')) {
      return token.substring(0, token.length - 2);
    }
    return token;
  }

  static double? _parseAmount(
    String text,
    Map<String, String> entities, {
    bool allowBareNumber = false,
  }) {
    final amountPattern = r'\d[\d,]*(?:\.\d{1,2})?';
    final patterns = <RegExp>[
      RegExp('(?:₹|rs\\.?|inr)\\s*($amountPattern)', caseSensitive: false),
      RegExp(
        '(?:ticket|paid|costs?|amount)\\s*(?:was|is|of|as|:)?\\s*(?:₹|rs\\.?|inr)?\\s*($amountPattern)',
        caseSensitive: false,
      ),
    ];
    if (allowBareNumber) {
      patterns.add(RegExp('^\\s*($amountPattern)\\s*\$', caseSensitive: false));
    }
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match == null) continue;
      final parsed = double.tryParse(match.group(1)!.replaceAll(',', ''));
      if (parsed != null && parsed.isFinite) return parsed;
    }
    return null;
  }

  static double? _parseHours(
    String text,
    Map<String, String> entities, {
    bool allowBareNumber = false,
  }) {
    final match = RegExp(
      r'(-?\d+(?:\.\d+)?)\s*(hours?|hrs?|days?)\b',
      caseSensitive: false,
    ).firstMatch(text);
    if (match != null) {
      final value = double.tryParse(match.group(1)!);
      if (value == null || !value.isFinite) return null;
      return match.group(2)!.toLowerCase().startsWith('day')
          ? value * 24
          : value;
    }
    if (allowBareNumber) {
      final bare = RegExp(r'^\s*(-?\d+(?:\.\d+)?)\s*$').firstMatch(text);
      if (bare != null) return double.tryParse(bare.group(1)!);
    }
    return null;
  }

  static bool _isRefundRequest(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('refund') ||
        normalized.contains('how much') &&
            (normalized.contains('back') || normalized.contains('get')) ||
        normalized.contains('calculate') && normalized.contains('refund');
  }

  static bool _isExplicitCancellation(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('want to cancel') ||
        normalized.contains("don't want") ||
        normalized.contains('do not want') ||
        normalized.contains('cancel my booking') ||
        normalized.contains('cancel my ticket');
  }

  static bool _isCancellationRequest(String text) {
    final normalized = text.toLowerCase();
    return normalized.contains('cancel') ||
        normalized.contains('cancellation') ||
        normalized.contains('refund');
  }

  static double _roundCurrency(double amount) =>
      (amount * 100).roundToDouble() / 100;

  static String _formatNumber(double value) => value == value.truncateToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}

class _FaqMatch {
  const _FaqMatch(this.faq, this.score);

  final TicketFaq? faq;
  final double score;
}
