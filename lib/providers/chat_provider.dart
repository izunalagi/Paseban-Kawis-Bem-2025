import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  ChatSession? _currentSession;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  Map<String, String> _sessionPreviews = {};
  static const String _prefsKeyPreviews = 'chat_session_previews';

  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  Map<String, String> get sessionPreviews => _sessionPreviews;

  ChatProvider() {
    _loadStoredPreviews();
  }

  Future<void> _loadStoredPreviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedPreviews = prefs.getString(_prefsKeyPreviews);
      if (storedPreviews != null) {
        _sessionPreviews = Map<String, String>.from(jsonDecode(storedPreviews));
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading stored previews: $e');
    }
  }

  Future<void> _saveStoredPreviews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKeyPreviews, jsonEncode(_sessionPreviews));
    } catch (e) {
      debugPrint('Error saving stored previews: $e');
    }
  }

  Future<void> startNewSession(String token) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentSession = await _chatService.startSession(token);
      _messages = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error starting session: $e');
      rethrow; // Let UI handle the error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String token, String message) async {
    if (_currentSession == null || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _chatService.sendMessage(token, _currentSession!.id, message);

      // Store first message as preview
      if (!_sessionPreviews.containsKey(_currentSession!.id)) {
        _sessionPreviews[_currentSession!.id] = message;
        await _saveStoredPreviews();
      }

      // Load updated chat history
      await loadChatHistory(token);
    } catch (e) {
      debugPrint('Error sending message: $e');
      rethrow;
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
      rethrow;
    }
  }

  Future<void> switchSession(String token, String sessionId) async {
    if (_isLoading || sessionId == _currentSession?.id) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentSession = ChatSession(id: sessionId);
      _messages = [];
      await loadChatHistory(token);
    } catch (e) {
      debugPrint('Error switching session: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> endSession(String token) async {
    if (_currentSession == null || _isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _chatService.endSession(token, _currentSession!.id);
      _sessionPreviews.remove(_currentSession!.id);
      await _saveStoredPreviews();
      _currentSession = null;
      _messages = [];
      notifyListeners();
    } catch (e) {
      debugPrint('Error ending session: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
