class ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  ChatMessage({required this.text, required this.isMe, DateTime? time})
      : time = time ?? DateTime.now();
}

class ChatConversation {
  final String id;
  final String name;
  final String subtitle;
  final String avatarText;
  final List<ChatMessage> messages;
  int unreadCount;
  bool isTyping;

  ChatConversation({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.avatarText,
    List<ChatMessage>? messages,
    this.unreadCount = 0,
    this.isTyping = false,
  }) : messages = messages ?? [];

  ChatMessage? get lastMessage => messages.isEmpty ? null : messages.last;
}
