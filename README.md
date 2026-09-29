# TicketBot

**NLP-Based Ticket Booking & Refund Assistant**

TicketBot is a Flutter web support prototype for ticket booking, cancellation, payment, ticket, refund, rescheduling, event, and account questions. FAQ retrieval and refund calculations run locally in the app; no backend or real payment data is required.

## Run locally

Requires Flutter 3.47.5 or compatible stable Flutter with web support enabled.

```sh
flutter pub get
flutter run -d chrome
```

## Verify and build

```sh
flutter test
flutter analyze
flutter build web --release
```

The production site is generated in `build/web`.

## NLP flow

TicketBot lowercases and tokenizes the input, removes stop words, applies lightweight suffix normalization, extracts keywords and entities, then creates TF-IDF vectors for the question and FAQ records. Cosine similarity ranks the FAQ records; the highest match is used only when its score meets the configurable `TicketBotService.confidenceThreshold` (default `0.12`). The FAQ's intent and category are shown in the optional NLP analysis panel.

For a cancellation/refund request, the service extracts an amount and remaining hours. If either value is missing, it asks for that value and keeps the conversation state in memory. The deterministic rule engine then calculates the fee and estimated refund; NLP does not generate or guess currency values.

## Demo Cancellation Policy

These rules are for the college project demonstration only, not a real ticketing company policy:

- More than 48 hours: 10% cancellation charge
- 24 to 48 hours: 20%
- 6 to 24 hours: 40%
- 2 to 6 hours: 60%
- Less than 2 hours: 100%

Refund = ticket amount - (ticket amount × cancellation percentage / 100). Values are rounded to paise. Negative, non-finite, and out-of-range calculator inputs are rejected.

## Netlify

Connect the repository to Netlify and use the checked-in `netlify.toml`. Its build script downloads the pinned Flutter SDK when needed, builds the web release, and publishes `build/web`. `web/_redirects` provides a fallback for client-side routes. To use another compatible Flutter release, change `FLUTTER_VERSION` in `netlify.toml`.

## Limitations

- Retrieval is deterministic and lightweight, not a hosted or trained ML model; paraphrases outside the FAQ vocabulary may fall back to the unknown response.
- Conversation state is kept only in the current browser session and is cleared by New conversation or a page refresh.
- Refund output is an estimate from the explicitly labeled demo policy. TicketBot does not access bookings, event systems, or payment providers.
- The old Flask educational backend remains in the repository but is not used by the TicketBot app or Netlify build.