import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../notifiers/chat_notifier.dart';
import '../../auth/notifiers/auth_notifier.dart';
import '../models/message_model.dart';
import '../../../core/api_service.dart';

class GroupChatScreen extends ConsumerStatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatScreen({super.key, required this.groupId, required this.groupName});

  @override
  ConsumerState<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends ConsumerState<GroupChatScreen> {
  final _messageController = TextEditingController();
  WebSocketChannel? _channel;
  final _storage = const FlutterSecureStorage();
  
  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    await ref.read(chatProvider(widget.groupId).notifier).loadHistory(widget.groupId);
    final jwt = await _storage.read(key: 'jwt');
    if (jwt != null) {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://10.0.2.2:8000/ws/groups/${widget.groupId}?token=$jwt'),
      );
      
      _channel!.stream.listen((message) {
        if (message is String) {
          final data = jsonDecode(message);
          final msg = MessageModel.fromJson(data);
          ref.read(chatProvider(widget.groupId).notifier).addMessage(msg);
        }
      });
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _channel == null) return;
    
    final content = _messageController.text.trim();
    final currentUser = ref.read(authProvider).value;
    
    final tempMsg = MessageModel(
      msgId: DateTime.now().millisecondsSinceEpoch.toString(), 
      content: content,
      senderId: currentUser?.userId ?? '',
      senderName: currentUser?.name ?? 'Me',
      groupId: widget.groupId,
      sentAt: DateTime.now().toIso8601String(),
    );
    
    ref.read(chatProvider(widget.groupId).notifier).addMessage(tempMsg);
    
    _channel!.sink.add(jsonEncode({'content': content, 'sender_id': currentUser?.userId, 'sender_name': currentUser?.name}));
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider(widget.groupId));
    final currentUser = ref.watch(authProvider).value;

    return Scaffold(
      appBar: AppBar(title: Text(widget.groupName)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true, 
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[messages.length - 1 - index];
                final isMe = msg.senderId == currentUser?.userId;

                return Align(
                  alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isMe ? Colors.blue : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isMe)
                          Text(msg.senderName ?? 'User', style: const TextStyle(fontSize: 10, color: Colors.black54)),
                        Text(msg.content, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
                        const SizedBox(height: 4),
                        Text(
                          msg.sentAt.split('T').last.substring(0, 5), 
                          style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
