import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/chatbot_response.dart';

class ApiService {
  // Base URL for the Flask backend. For web deployment, set
  // --dart-define=API_BASE_URL=https://your-backend.example.com
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000',
  );

  // Session ID to maintain conversation context across messages.
  String _sessionId = '';

  ApiService() {
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Sends a chat message to the Flask NLP backend and returns the response.
  Future<ChatbotResponse> sendMessage(
    String message, {
    required String mode,
    bool includeNlpAnalysis = false,
  }) async {
    try {
      final uri = Uri.parse('$_baseUrl/chat');
      final body = jsonEncode({
        'message': message,
        'mode': mode.toLowerCase(),
        'conversation_id': _sessionId,
        'session_id': _sessionId,
        'include_nlp': includeNlpAnalysis,
      });

      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: body,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return ChatbotResponse.fromJson(data);
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return ChatbotResponse.error(
          'Server returned an error (${response.statusCode}). Please try again.',
        );
      }
    } on http.ClientException catch (e) {
      debugPrint('HTTP Client Error: $e');
      return ChatbotResponse.error(
        'Could not connect to StudyMate backend. '
        'Please ensure the Flask server is running on port 5000.',
      );
    } catch (e) {
      debugPrint('Unexpected error: $e');
      return ChatbotResponse.error('Something went wrong. Please try again.');
    }
  }

  /// Resets the conversation context on the backend for this session.
  Future<void> resetSession() async {
    try {
      final uri = Uri.parse('$_baseUrl/conversation/reset');
      await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'conversation_id': _sessionId,
          'session_id': _sessionId,
        }),
      );
    } catch (e) {
      debugPrint('Reset session error: $e');
    }
    _sessionId = DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Health check for the Flask backend.
  Future<bool> isBackendHealthy() async {
    try {
      final uri = Uri.parse('$_baseUrl/health');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
