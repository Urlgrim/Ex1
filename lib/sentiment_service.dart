import 'dart:convert';
import 'package:http/http.dart' as http;

class SentimentService {
  final String _endpoint = 'https://your-ngrok-url.ngrok-free.app/analyze'; // Đổi đúng URL

  Future<String> analyzeSentiment(String content) async {
    try {
      final uri = Uri.parse(_endpoint);
      final result = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'text': content}),
      );

      if (result.statusCode == 200) {
        final response = jsonDecode(result.body);
        final sentiment = response['sentiment'];
        if (sentiment is String) {
          return sentiment;
        } else {
          throw Exception('Kết quả không hợp lệ từ API');
        }
      } else {
        throw Exception(
          'Gọi API thất bại - Mã trạng thái: ${result.statusCode}\nNội dung: ${result.body}',
        );
      }
    } catch (error) {
      throw Exception('Phân tích thất bại: $error');
    }
  }
}
