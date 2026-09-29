import 'package:flutter_test/flutter_test.dart';
import 'package:studymate/services/ticketbot_service.dart';

void main() {
  group('TicketBot retrieval', () {
    test('maps natural booking variations to the booking FAQ', () {
      final response = TicketBotService().respond(
        'How can I reserve a ticket?',
      );

      expect(response.intent, 'ticket_booking');
      expect(response.faqId, 'BOOK001');
      expect(response.similarity, greaterThan(0.12));
      expect(response.text, contains('select a date'));
    });

    test('maps generic booking wording to the booking procedure FAQ', () {
      for (final question in ['jow do i book ticket', 'how do i book ticket']) {
        final response = TicketBotService().respond(question);

        expect(response.intent, 'ticket_booking');
        expect(response.faqId, 'BOOK001');
        expect(response.text, contains('Choose an event'));
      }
    });

    test('keeps refund timing questions on their FAQ answer', () {
      final response = TicketBotService().respond(
        'How long does a refund take?',
      );

      expect(response.intent, 'refund_timing');
      expect(response.faqId, 'REF002');
      expect(response.text, contains('timelines'));
    });

    test('returns a controlled fallback for unrelated input', () {
      final response = TicketBotService().respond('Tell me a joke');

      expect(response.intent, 'unknown');
      expect(response.text, contains('not confident'));
    });

    test(
      'detects credential values but not normal password-help questions',
      () {
        expect(
          TicketBotService.containsSensitiveInformation('CVV: 123'),
          isTrue,
        );
        expect(
          TicketBotService.containsSensitiveInformation('4111 1111 1111 1111'),
          isTrue,
        );
        expect(
          TicketBotService.containsSensitiveInformation(
            'I forgot my password.',
          ),
          isFalse,
        );
        expect(
          TicketBotService.containsSensitiveInformation(
            'My password is hunter2',
          ),
          isTrue,
        );

        final response = TicketBotService().respond('I forgot my password.');
        expect(response.intent, 'account_support');
      },
    );
  });

  group('TicketBot refund flow', () {
    test('collects amount then time and calculates without guessing', () {
      final service = TicketBotService();

      final first = service.respond('I want to cancel my ticket.');
      expect(first.text, contains('ticket amount'));

      final second = service.respond('₹1500');
      expect(second.text, contains('How many hours'));

      final third = service.respond('10 hours');
      expect(third.text, contains('Cancellation charge: 40%'));
      expect(third.text, contains('Cancellation amount: ₹600'));
      expect(third.text, contains('Estimated refund: ₹900'));
      expect(third.ruleEngine, '6–24 hours');
      expect(third.entities['ticket_amount'], '₹1,500');
      expect(third.entities['remaining_hours'], '10 hours');
    });

    test('extracts amount and time from a single message', () {
      final response = TicketBotService().respond(
        'I paid ₹2,000 and my event is 30 hours away. How much will I get?',
      );

      expect(response.text, contains('Cancellation amount: ₹400'));
      expect(response.text, contains('Estimated refund: ₹1,600'));
    });

    test('supports reset and rejects invalid follow-up values', () {
      final service = TicketBotService();
      service.respond('I want to cancel my ticket.');
      final invalid = service.respond('-5');
      expect(invalid.text, contains('valid non-negative ticket amount'));

      service.reset();
      expect(service.awaitingField, isNull);
      expect(service.ticketAmount, isNull);
      expect(service.remainingHours, isNull);
    });
  });

  group('Demo cancellation policy', () {
    test('applies exact policy ranges and rounded amounts', () {
      expect(
        TicketBotService.calculateRefund(1000, 50).cancellationPercent,
        10,
      );
      expect(
        TicketBotService.calculateRefund(1000, 48).cancellationPercent,
        20,
      );
      expect(
        TicketBotService.calculateRefund(1000, 24).cancellationPercent,
        20,
      );
      expect(TicketBotService.calculateRefund(750, 3).cancellationPercent, 60);
      expect(TicketBotService.calculateRefund(1000, 2).cancellationPercent, 60);
      expect(
        TicketBotService.calculateRefund(1000, 1.99).cancellationPercent,
        100,
      );

      final decimal = TicketBotService.calculateRefund(1250.5, 30);
      expect(decimal.cancellationFee, 250.1);
      expect(decimal.refundAmount, 1000.4);
    });

    test('rejects negative and non-finite inputs', () {
      expect(
        () => TicketBotService.calculateRefund(-1, 10),
        throwsArgumentError,
      );
      expect(
        () => TicketBotService.calculateRefund(100, double.infinity),
        throwsArgumentError,
      );
    });
  });
}
