import 'api_model.dart';

class ChatRoom {
  final String id;
  final String name;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  ApiModel selectedApi;

  ChatRoom({
    required this.id,
    required this.name,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    ApiModel? selectedApi,
  }) : messages = messages ?? [],
       createdAt = createdAt ?? DateTime.now(),
       selectedApi = selectedApi ?? ApiConfig.getDefaultApi();
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
} 