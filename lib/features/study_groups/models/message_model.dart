class MessageModel {
  final String msgId;
  final String content;
  final String senderId;
  final String? senderName;
  final String groupId;
  final String sentAt;

  MessageModel({
    required this.msgId,
    required this.content,
    required this.senderId,
    this.senderName,
    required this.groupId,
    required this.sentAt,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      msgId: json['msg_id'] as String,
      content: json['content'] as String,
      senderId: json['sender_id'] as String,
      senderName: json['sender_name'] as String?,
      groupId: json['group_id'] as String,
      sentAt: json['sent_at'] as String,
    );
  }
}
