import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  ChatSession? _currentSession;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  List<ChatSessionPreview> _sessionPreviews = [];
  static const String _prefsKeyCurrentSession = 'current_chat_session';

  ChatSession? get currentSession => _currentSession;
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  List<ChatSessionPreview> get sessionPreviews => _sessionPreviews;

  // Getter untuk compatibility dengan kode lama
  Map<String, String> get sessionPreviewsMap {
    final Map<String, String> map = {};
    for (final preview in _sessionPreviews) {
      map[preview.id] = preview.previewText;
    }
    return map;
  }

  ChatProvider() {
    _loadCurrentSession();
  }

  Future<void> _loadCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionId = prefs.getString(_prefsKeyCurrentSession);
      if (sessionId != null) {
        _currentSession = ChatSession(id: sessionId);
      }
    } catch (e) {
      debugPrint('Error loading current session: $e');
    }
  }

  Future<void> _saveCurrentSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentSession != null) {
        await prefs.setString(_prefsKeyCurrentSession, _currentSession!.id);
      } else {
        await prefs.remove(_prefsKeyCurrentSession);
      }
    } catch (e) {
      debugPrint('Error saving current session: $e');
    }
  }

  // Load semua sessions dari server
  Future<void> loadAllSessions(String token) async {
    try {
      _sessionPreviews = await _chatService.getAllSessions(token);
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading all sessions: $e');
      // Tidak throw error agar UI tidak crash
    }
  }

  Future<void> startNewSession(String token) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      _currentSession = await _chatService.startSession(token);
      _messages = [];
      await _saveCurrentSession();

      // Reload sessions setelah membuat session baru
      await loadAllSessions(token);

      notifyListeners();
    } catch (e) {
      debugPrint('Error starting session: $e');
      rethrow;
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

      // Load updated chat history
      await loadChatHistory(token);

      // Reload sessions untuk update preview
      await loadAllSessions(token);
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
      await _saveCurrentSession();
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

      // Remove dari local storage
      await _saveCurrentSession();

      // Reload sessions
      await loadAllSessions(token);

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

  // Method untuk initialize provider saat pertama kali masuk halaman chat
  Future<void> initializeChat(String token) async {
    // Load semua sessions dulu
    await loadAllSessions(token);

    // Jika ada current session yang tersimpan, load historynya
    if (_currentSession != null) {
      try {
        await loadChatHistory(token);
      } catch (e) {
        // Jika gagal load history, mungkin session sudah tidak valid
        _currentSession = null;
        _messages = [];
        await _saveCurrentSession();
        notifyListeners();
      }
    }
  }
}
