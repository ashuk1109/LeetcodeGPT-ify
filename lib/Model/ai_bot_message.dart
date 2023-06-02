class MessageFromAIBot {
  final String role;
  final String content;

  MessageFromAIBot({required this.role, required this.content});

  Map<String, dynamic> toJson() => {
    'role': role,
    'content': content,
  };

  factory MessageFromAIBot.fromJson(Map<String, dynamic> json) {
    return MessageFromAIBot(
      role: 'role',
      content: 'content',
    );
  }
}