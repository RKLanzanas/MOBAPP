import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../state/chat_state.dart';
import '../../theme/app_theme.dart';

String formatChatTime(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  if (diff.inDays >= 1) return '${diff.inDays}d ago';
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${time.hour < 12 ? 'AM' : 'PM'}';
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatState = ChatStateScope.of(context);
    final conversations = chatState.conversations;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(title: const Text('Chats'), centerTitle: true),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        itemCount: conversations.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final convo = conversations[index];
          final last = convo.lastMessage;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ChatScreen(conversationId: convo.id)),
            ),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.borderSubtle, width: 1.2),
              ),
              child: Row(
                children: [
                  _Avatar(text: convo.avatarText),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          convo.name,
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          convo.isTyping
                              ? 'typing...'
                              : (last == null
                                  ? convo.subtitle
                                  : '${last.isMe ? 'You: ' : ''}${last.text}'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: convo.unreadCount > 0 ? AppTheme.textDark : AppTheme.textMuted,
                            fontSize: 12,
                            fontWeight:
                                convo.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                            fontStyle: convo.isTyping ? FontStyle.italic : FontStyle.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (last != null)
                        Text(
                          formatChatTime(last.time),
                          style: TextStyle(color: AppTheme.textMuted, fontSize: 10),
                        ),
                      const SizedBox(height: 6),
                      if (convo.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.badgeRed,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${convo.unreadCount}',
                            style: const TextStyle(
                              color: AppTheme.alwaysWhite,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String text;
  final double size;
  const _Avatar({required this.text, this.size = 48});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: AppTheme.darkBluePrimary, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.pureWhite,
          fontSize: size * 0.32,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String conversationId;
  const ChatScreen({super.key, required this.conversationId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  int _lastCount = 0;

  static const List<String> _quickReplies = [
    'Do you accept GCash?',
    'Any discount codes?',
    'How long is shipping?',
    'Can I pay via COD?',
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final chatState = ChatStateScope.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      chatState.markAsRead(widget.conversationId);
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? preset]) {
    final text = preset ?? _messageController.text;
    if (text.trim().isEmpty) return;
    ChatStateScope.of(context).sendMessage(widget.conversationId, text);
    _messageController.clear();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ChatStateScope.of(context);
    final convo = chatState.conversationById(widget.conversationId);
    final messages = convo.messages;

    if (messages.length != _lastCount) {
      _lastCount = messages.length;
      _scrollToBottom();
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            _Avatar(text: convo.avatarText, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    convo.name,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppTheme.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    convo.isTyping ? 'typing...' : 'Online',
                    style: TextStyle(
                      color: convo.isTyping ? AppTheme.darkBlueAccent : AppTheme.successGreen,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              itemCount: messages.length + (convo.isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == messages.length) return const _TypingBubble();
                return _MessageBubble(message: messages[index]);
              },
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _quickReplies.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ActionChip(
                label: Text(
                  _quickReplies[index],
                  style: TextStyle(color: AppTheme.darkBluePrimary, fontSize: 12),
                ),
                backgroundColor: AppTheme.pureWhite,
                side: BorderSide(color: AppTheme.borderSubtle),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                onPressed: () => _send(_quickReplies[index]),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              decoration: BoxDecoration(
                color: AppTheme.pureWhite,
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      style: TextStyle(color: AppTheme.textDark, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        filled: true,
                        fillColor: AppTheme.backgroundLight,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: AppTheme.darkBluePrimary),
                    icon: Icon(Icons.send_rounded, color: AppTheme.pureWhite, size: 20),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.darkBluePrimary : AppTheme.pureWhite,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          border: isMe ? null : Border.all(color: AppTheme.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: isMe ? AppTheme.pureWhite : AppTheme.textDark,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formatChatTime(message.time),
              style: TextStyle(
                color: (isMe ? AppTheme.pureWhite : AppTheme.textMuted).withValues(alpha: 0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.pureWhite,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Text('typing...', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ),
    );
  }
}
