import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';

/// In-app chats between the customer and Burgis Perfume staff.
/// Replies are generated automatically so the feature works offline.
class ChatState extends ChangeNotifier {
  final List<ChatConversation> _conversations = [
    ChatConversation(
      id: 'support',
      name: 'Scentiments Support',
      subtitle: 'Orders, payments & deliveries',
      avatarText: 'CS',
      unreadCount: 1,
      messages: [
        ChatMessage(
          text: 'Hi! Welcome to Scentiments 👋 How can we help you today?',
          isMe: false,
          time: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
      ],
    ),
    ChatConversation(
      id: 'advisor',
      name: 'Scent Advisor',
      subtitle: 'Find your signature fragrance',
      avatarText: 'SA',
      unreadCount: 1,
      messages: [
        ChatMessage(
          text: 'Hello! Tell me what scents you love (floral, woody, fresh, sweet) '
              'and I\'ll recommend a Scentiments fragrance for you.',
          isMe: false,
          time: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
    ChatConversation(
      id: 'promos',
      name: 'Scentiments Promos',
      subtitle: 'Discounts & vouchers',
      avatarText: 'SC',
      messages: [
        ChatMessage(
          text: '🎉 Use code SCENT10 to get 10% off your next order. '
              'New member? Try WELCOME100 for ₱100 off, or SCENTIMENTS20 for 20% off ₱2,500+!',
          isMe: false,
          time: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
    ),
  ];

  final List<Timer> _timers = [];

  List<ChatConversation> get conversations => _conversations;

  int get totalUnread => _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  ChatConversation conversationById(String id) =>
      _conversations.firstWhere((c) => c.id == id);

  void markAsRead(String id) {
    final convo = conversationById(id);
    if (convo.unreadCount == 0) return;
    convo.unreadCount = 0;
    notifyListeners();
  }

  void sendMessage(String conversationId, String text, {bool isViewing = true}) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    final convo = conversationById(conversationId);
    convo.messages.add(ChatMessage(text: trimmed, isMe: true));
    convo.isTyping = true;
    notifyListeners();

    final timer = Timer(const Duration(milliseconds: 1400), () {
      convo.isTyping = false;
      convo.messages.add(ChatMessage(text: _autoReply(convo.id, trimmed), isMe: false));
      notifyListeners();
    });
    _timers.add(timer);
  }

  String _autoReply(String conversationId, String message) {
    final m = message.toLowerCase();

    if (conversationId == 'advisor') {
      if (m.contains('floral') || m.contains('rose') || m.contains('flower')) {
        return 'For floral lovers I recommend No. 6 Pure Rose Petal Infusion or '
            'No. 9 Blanc Pure Minimalist 🌹';
      }
      if (m.contains('wood') || m.contains('oak') || m.contains('leather')) {
        return 'Try No. 2 Matte Noir Intense or No. 8 Cuir Artisan Atelier — bold and woody.';
      }
      if (m.contains('fresh') || m.contains('aqua') || m.contains('clean')) {
        return 'No. 3 Aqua Teardrop Elixir and No. 5 Vert Botanique Column are perfect fresh scents.';
      }
      if (m.contains('sweet') || m.contains('vanilla') || m.contains('gourmand')) {
        return 'You\'ll love No. 7 Cognac Crystal Reserve — vanilla praline and cognac ✨';
      }
      return 'Interesting! Could you tell me if you prefer floral, woody, fresh, or sweet scents?';
    }

    if (conversationId == 'promos') {
      return 'Available codes: SCENT10 (10% off), WELCOME100 (₱100 off), '
          'PAYDAY15 (15% off ₱5,000+), FREESHIP (free shipping), SCENTIMENTS20 (20% off ₱2,500+). Enter them in your basket!';
    }

    // Customer support
    if (m.contains('gcash')) {
      return 'Yes! We accept GCash. Just choose GCash as your payment method at checkout.';
    }
    if (m.contains('cod') || m.contains('cash on delivery') || m.contains('cash')) {
      return 'Cash on Delivery is available nationwide. Please prepare the exact amount 😊';
    }
    if (m.contains('bank')) {
      return 'We accept bank transfers via BDO, BPI, Metrobank, Landbank, Security Bank and UnionBank.';
    }
    if (m.contains('discount') || m.contains('promo') || m.contains('voucher') || m.contains('code')) {
      return 'You can use SCENT10 for 10% off your order. Apply it in your basket before checkout!';
    }
    if (m.contains('ship') || m.contains('deliver') || m.contains('order')) {
      return 'Orders arrive within 2-3 business days. Shipping is FREE for orders ₱3,500 and above.';
    }
    if (m.contains('refund') || m.contains('return')) {
      return 'We accept returns within 7 days for unopened items. Please send your order number.';
    }
    if (m.contains('thank')) {
      return 'You\'re welcome! Happy shopping at Scentiments 💙';
    }
    if (m.contains('hi') || m.contains('hello')) {
      return 'Hello! How can we help you today?';
    }
    return 'Thanks for your message! A Scentiments representative will get back to you shortly.';
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }
}

class ChatStateScope extends InheritedNotifier<ChatState> {
  const ChatStateScope({
    super.key,
    required ChatState super.notifier,
    required super.child,
  });

  static ChatState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ChatStateScope>()!.notifier!;
  }
}
