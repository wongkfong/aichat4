import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/chat_service.dart';
import 'models/chat_room.dart';
import 'services/chat_room_service.dart';
import 'models/api_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI ChatBox',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const ChatRoomList(),
    );
  }
}

class ChatRoomList extends StatefulWidget {
  const ChatRoomList({super.key});

  @override
  State<ChatRoomList> createState() => _ChatRoomListState();
}

class _ChatRoomListState extends State<ChatRoomList> {
  final ChatRoomService _roomService = ChatRoomService();
  final TextEditingController _roomNameController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _apiKeyController.text = ApiConfig.apiKey;
  }

  @override
  void dispose() {
    _roomNameController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  void _createNewRoom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('新增聊天室'),
        content: TextField(
          controller: _roomNameController,
          decoration: const InputDecoration(
            labelText: '聊天室名稱',
            hintText: '請輸入聊天室名稱',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (_roomNameController.text.isNotEmpty) {
                setState(() {
                  _roomService.createRoom(_roomNameController.text);
                });
                _roomNameController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('建立'),
          ),
        ],
      ),
    );
  }

  void _deleteRoom(String roomId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('刪除聊天室'),
        content: const Text('確定要刪除這個聊天室嗎？此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _roomService.deleteRoom(roomId);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('刪除'),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('設置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('API Key'),
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(
                  hintText: '請輸入您的 OpenRouter API Key',
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              const Text('溫度 (Temperature)'),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: ApiConfig.temperature,
                      min: 0.0,
                      max: 2.0,
                      divisions: 20,
                      label: ApiConfig.temperature.toStringAsFixed(1),
                      onChanged: (value) {
                        setState(() {
                          ApiConfig.updateTemperature(value);
                        });
                      },
                    ),
                  ),
                  Text(
                    ApiConfig.temperature.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '溫度值越高，回應越具創意性；溫度值越低，回應越保守準確。',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                if (_apiKeyController.text.isNotEmpty) {
                  ApiConfig.updateApiKey(_apiKeyController.text);
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('設置已更新')),
                );
              },
              child: const Text('保存'),
            ),
            TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: ApiConfig.apiKey));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('API Key 已複製到剪貼板')),
                );
              },
              child: const Text('複製 API Key'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('聊天室列表'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: '設置',
          ),
        ],
      ),
      body: _roomService.rooms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '還沒有聊天室',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '點擊右下角的按鈕來創建新的聊天室',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: _roomService.rooms.length,
              itemBuilder: (context, index) {
                final room = _roomService.rooms[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text(
                        room.name[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(room.name),
                    subtitle: Text(
                      '建立於 ${_formatDate(room.createdAt)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => _deleteRoom(room.id),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            roomId: room.id,
                            roomName: room.name,
                            chatRoomService: _roomService,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewRoom,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month}/${date.day} ${date.hour}:${date.minute}';
  }
}

class ChatScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final ChatRoomService chatRoomService;

  const ChatScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.chatRoomService,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  bool _isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;

    final room = widget.chatRoomService.getRoomById(widget.roomId);
    if (room == null) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
    );

    setState(() {
      widget.chatRoomService.addMessageToRoom(widget.roomId, userMessage);
      _isLoading = true;
    });

    _messageController.clear();

    try {
      final response = await _chatService.sendMessage(text, room.selectedApi);
      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
      );
      
      setState(() {
        _isLoading = false;
        widget.chatRoomService.addMessageToRoom(widget.roomId, aiMessage);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        widget.chatRoomService.addMessageToRoom(
          widget.roomId,
          ChatMessage(
            text: '錯誤: 無法獲取回應',
            isUser: false,
          ),
        );
      });
    }
  }

  void _showApiSelector() {
    final room = widget.chatRoomService.getRoomById(widget.roomId);
    if (room == null) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '選擇AI模型',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...ApiConfig.availableApis.map((api) => ListTile(
              title: Text(api.name),
              subtitle: Text(api.description),
              leading: Radio<String>(
                value: api.id,
                groupValue: room.selectedApi.id,
                onChanged: (value) {
                  setState(() {
                    room.selectedApi = ApiConfig.availableApis
                        .firstWhere((a) => a.id == value);
                  });
                  Navigator.pop(context);
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final room = widget.chatRoomService.getRoomById(widget.roomId);
    if (room == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('錯誤'),
        ),
        body: const Center(
          child: Text('找不到聊天室'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.roomName),
            Text(
              '使用: ${room.selectedApi.name}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.api),
            onPressed: _showApiSelector,
            tooltip: '選擇AI模型',
          ),
        ],
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.background,
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                itemCount: room.messages.length,
                itemBuilder: (context, index) => _buildMessage(room.messages[index]),
              ),
            ),
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 16),
                    Text(
                      'AI正在思考中...',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _messageController,
                              decoration: const InputDecoration(
                                hintText: '輸入訊息...',
                                border: InputBorder.none,
                              ),
                              onSubmitted: _handleSubmitted,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: () => _handleSubmitted(_messageController.text),
                        elevation: 0,
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(message.isUser),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 5),
                      bottomRight: Radius.circular(message.isUser ? 5 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
                Text(
                  _formatTime(message.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (message.isUser) _buildAvatar(message.isUser),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isUser) {
    return CircleAvatar(
      backgroundColor: isUser
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).colorScheme.secondary,
      child: Icon(
        isUser ? Icons.person : Icons.android,
        color: Colors.white,
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
