import 'package:uuid/uuid.dart';
import '../models/chat_room.dart';

class ChatRoomService {
  final List<ChatRoom> _rooms = [];
  final _uuid = const Uuid();

  List<ChatRoom> get rooms => List.unmodifiable(_rooms);

  ChatRoom createRoom(String name) {
    final room = ChatRoom(
      id: _uuid.v4(),
      name: name,
    );
    _rooms.add(room);
    return room;
  }

  void deleteRoom(String id) {
    _rooms.removeWhere((room) => room.id == id);
  }

  void addMessageToRoom(String roomId, ChatMessage message) {
    final room = _rooms.firstWhere((room) => room.id == roomId);
    room.messages.insert(0, message);
  }

  ChatRoom? getRoomById(String id) {
    try {
      return _rooms.firstWhere((room) => room.id == id);
    } catch (_) {
      return null;
    }
  }
} 