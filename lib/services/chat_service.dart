import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_model.dart';

class ChatService {
  final String baseUrl = "http://10.0.2.2:8000/api";

  Future<ChatSession> startSession(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/start'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ChatSession.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to start chat session');
    }
  }

  Future<String> sendMessage(
    String token,
    String sessionId,
    String prompt,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/send'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({'session_id': sessionId, 'prompt': prompt}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['reply'];
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<List<ChatMessage>> getSessionHistory(
    String token,
    String sessionId,
  ) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/history/$sessionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['logs'] as List)
          .map((log) => ChatMessage.fromJson(log))
          .toList();
    } else {
      throw Exception('Failed to get chat history');
    }
  }

  // Method baru untuk mendapatkan semua sessions
  Future<List<ChatSessionPreview>> getAllSessions(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/chat/sessions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['sessions'] as List)
          .map((session) => ChatSessionPreview.fromJson(session))
          .toList();
    } else {
      throw Exception('Failed to get chat sessions');
    }
  }

  Future<void> endSession(String token, String sessionId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/chat/end/$sessionId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to end chat session');
    }
  }
}
