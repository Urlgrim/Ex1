import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  static const _baseUrl = 'https://newsapi.org/v2/top-headlines';
  static const _apiKey = 'your_api_key_here'; // Thay bằng key thật
  static const _country = 'us';
  static const _category = 'general';

  Future<List<Map<String, dynamic>>> fetchNews({int page = 1, int pageSize = 10}) async {
    final uri = Uri.parse(
      '$_baseUrl?country=$_country&category=$_category&page=$page&pageSize=$pageSize&apiKey=$_apiKey',
    );

    final reply = await http.get(uri);

    if (reply.statusCode == 200) {
      final data = jsonDecode(reply.body);
      if (data['status'] == 'ok' && data['articles'] != null) {
        return List<Map<String, dynamic>>.from(data['articles']);
      } else {
        throw Exception('Lỗi khi đọc dữ liệu từ News API');
      }
    } else {
      throw Exception('Lỗi kết nối: ${reply.statusCode}');
    }
  }
}
