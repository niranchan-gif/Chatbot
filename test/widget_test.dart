import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studymate/app.dart';

void main() {
  testWidgets('TicketBot dashboard shows chat, FAQ, and NLP analysis', (
    tester,
  ) async {
    await tester.pumpWidget(const TicketBotApp());

    expect(find.text('TicketBot'), findsOneWidget);
    expect(find.text('Support chat'), findsOneWidget);
    expect(find.text('Frequently asked questions'), findsOneWidget);
    expect(find.text('NLP analysis'), findsOneWidget);
    expect(find.textContaining('Send a question to see'), findsOneWidget);
    expect(find.text('Refund calculator'), findsNothing);
    expect(find.text('Demo Mode'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('chat updates its always-visible NLP analysis panel', (
    tester,
  ) async {
    await tester.pumpWidget(const TicketBotApp());

    final messageField = find.byType(TextField).first;
    await tester.ensureVisible(messageField);
    await tester.enterText(messageField, 'How can I reserve a ticket?');
    final sendButton = find.byTooltip('Send message');
    await tester.ensureVisible(sendButton);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(find.textContaining('Choose an event'), findsOneWidget);
    expect(find.text('NLP analysis'), findsOneWidget);
    expect(find.text('ticket_booking'), findsOneWidget);
    expect(find.text('BOOK001'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sensitive-looking card input is redacted from chat', (
    tester,
  ) async {
    await tester.pumpWidget(const TicketBotApp());

    final messageField = find.byType(TextField).first;
    await tester.ensureVisible(messageField);
    await tester.enterText(messageField, 'Card number: 4111 1111 1111 1111');
    final sendButton = find.byTooltip('Send message');
    await tester.ensureVisible(sendButton);
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(find.text('[Sensitive information removed]'), findsOneWidget);
    expect(find.textContaining('4111'), findsNothing);
    expect(find.textContaining('have not retained'), findsOneWidget);
  });
}
