import 'package:flutter/material.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  ChatSession? _currentSession;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  Future<void> startNewSession(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentSession = await _chatService.startSession(token);
      _messages = [];
    } catch (e) {
      debugPrint('Error starting session: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String token, String message) async {
    if (_currentSession == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chatService.sendMessage(
        token,
        _currentSession!.id,
        message,
      );

      // Load updated chat history
      await loadChatHistory(token);
    } catch (e) {
      debugPrint('Error sending message: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadChatHistory(String token) async {
    if (_currentSession == null) return;

    try {
      _messages = await _chatService.getSessionHistory(
        token,
        _currentSession!.id,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading chat history: $e');
    }
  }

  Future<void> endSession(String token) async {
    if (_currentSession == null) return;

    try {
      await _chatService.endSession(token, _currentSession!.id);
      _currentSession = null;
      _messages = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error ending session: $e');
    }
  }
}
