import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/api_model.dart';

class ChatService {
  Future<String> sendMessage(String message, ApiModel api) async {
    try {
      print('Sending message to API: $message using ${api.name}');
      
      final encodedMessage = utf8.encode(message);
      final decodedMessage = utf8.decode(encodedMessage);
      
      final Map<String, dynamic> requestBody = {
        'model': api.modelName,
        'messages': [
          {
            'role': 'system',
            'content': '你是一個有幫助的AI助手。請以用戶使用的語言來回答問題。Follow the language style and type (Traditional/Simplified Chinese, English, etc.) that the user uses in their message.'
          },
          {
            'role': 'user',
            'content': decodedMessage,
          }
        ],
        'temperature': ApiConfig.temperature,
        'max_tokens': 1000,
      };

      print('Request body: ${jsonEncode(requestBody)}');
      print('Using temperature: ${ApiConfig.temperature}');

      final response = await http.post(
        Uri.parse(ApiConfig.baseUrl),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer ${ApiConfig.apiKey}',
          'HTTP-Referer': 'https://openrouter.ai/docs',
          'X-Title': 'Flutter AI ChatBox',
          'Accept': 'application/json; charset=utf-8',
        },
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBytes = response.bodyBytes;
        final responseString = utf8.decode(responseBytes);
        print('Decoded response: $responseString');
        
        final data = jsonDecode(responseString);
        if (data['choices'] != null && 
            data['choices'].isNotEmpty && 
            data['choices'][0]['message'] != null) {
          final content = data['choices'][0]['message']['content'];
          return utf8.decode(utf8.encode(content));
        } else {
          return '無法解析AI的回應，請重試。';
        }
      } else {
        print('Error status code: ${response.statusCode}');
        print('Error response: ${response.body}');
        return '錯誤: 伺服器返回 ${response.statusCode}。請稍後再試。';
      }
    } catch (e) {
      print('Exception caught: $e');
      return '錯誤: 網路或伺服器錯誤。請稍後再試。';
    }
  }
}
