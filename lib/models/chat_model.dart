class ChatSession {
  final String id;

  ChatSession({required this.id});

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(id: json['session_id'].toString());
  }
}

class ChatMessage {
  final String prompt;
  final String response;
  final DateTime? createdAt;

  ChatMessage({required this.prompt, required this.response, this.createdAt});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      prompt: json['prompt'] ?? '',
      response: json['response'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }
}

// Model baru untuk session preview
class ChatSessionPreview {
  final String id;
  final String? firstMessage;
  final DateTime? createdAt;

  ChatSessionPreview({required this.id, this.firstMessage, this.createdAt});

  factory ChatSessionPreview.fromJson(Map<String, dynamic> json) {
    return ChatSessionPreview(
      id: json['id'].toString(),
      firstMessage: json['latest_message']?['prompt'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  String get previewText {
    if (firstMessage == null || firstMessage!.isEmpty) {
      return 'Chat baru';
    }
    final words = firstMessage!.trim().split(' ');
    if (words.length <= 5) return firstMessage!;
    return '${words.take(5).join(' ')}...';
  }
}
