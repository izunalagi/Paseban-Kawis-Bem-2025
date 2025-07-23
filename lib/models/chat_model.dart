class ChatMessage {
  final String prompt;
  final String response;
  final DateTime createdAt;

  ChatMessage({
    required this.prompt,
    required this.response,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      prompt: json['prompt'],
      response: json['response'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class ChatSession {
  final String id;
  DateTime? endedAt;

  ChatSession({required this.id, this.endedAt});

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['session_id'].toString(),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'])
          : null,
    );
  }
}
