import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../../../core/api_service.dart';

class ChatNotifier extends StateNotifier<List<MessageModel>> {
  ChatNotifier() : super([]);

  Future<void> loadHistory(String groupId) async {
    try {
      final response = await apiService.get('/groups/$groupId/messages');
      
      final rawData = response is List 
          ? response 
          : (response['data'] as List? ?? []);
          
      state = rawData.map((e) => MessageModel.fromJson(e)).toList();
    } catch (e) {
      // Ignored for now
    }
  }

  void addMessage(MessageModel message) {
    if (!state.any((m) => m.msgId == message.msgId)) {
      state = [...state, message];
    }
  }
}

final chatProvider = StateNotifierProvider.family<ChatNotifier, List<MessageModel>, String>((ref, groupId) {
  return ChatNotifier();
});
