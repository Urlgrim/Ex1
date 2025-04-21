import 'package:flutter/material.dart';
import 'news_service.dart';
import 'sentiment_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  final _newsFetcher = NewsService();
  final _sentimentAnalyzer = SentimentService();
  final List<Map<String, dynamic>> _items = [];
  final ScrollController _controller = ScrollController();

  int _pageIndex = 1;
  bool _fetching = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_controller.offset >= _controller.position.maxScrollExtent - 100 &&
        !_fetching &&
        _hasMore) {
      _loadArticles();
    }
  }

  Future<void> _loadArticles() async {
    setState(() => _fetching = true);
    try {
      final results = await _newsFetcher.fetchNews(page: _pageIndex);
      if (results.isEmpty) {
        setState(() => _hasMore = false);
      } else {
        final processed = await Future.wait(results.map((e) async {
          final item = Map<String, dynamic>.from(e);
          final content = item['title'] ?? item['description'] ?? '';
          item['sentiment'] = content.isEmpty
              ? 'N/A'
              : await _sentimentAnalyzer.analyzeSentiment(content).catchError((_) => 'Error');
          return item;
        }));
        setState(() {
          _items.addAll(processed);
          _pageIndex++;
        });
      }
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Load failed: $err')));
    } finally {
      setState(() => _fetching = false);
    }
  }

  Color _sentimentColor(String label) {
    switch (label.toLowerCase()) {
      case 'very positive':
        return Colors.teal;
      case 'positive':
        return Colors.lightGreen;
      case 'neutral':
        return Colors.grey;
      case 'negative':
        return Colors.deepOrange;
      case 'very negative':
        return Colors.red;
      case 'error':
        return Colors.blueGrey;
      default:
        return Colors.black45;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tin Tức & Cảm Xúc', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: _items.isEmpty && _fetching
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        controller: _controller,
        itemCount: _items.length + (_fetching ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final article = _items[index];
          final img = article['urlToImage'];
          final label = article['sentiment'] ?? '...';

          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (img != null && img != '')
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.network(
                      img,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 180,
                        color: Colors.grey[300],
                        child: const Center(child: Icon(Icons.broken_image)),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article['title'] ?? 'Không có tiêu đề',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        article['description'] ?? 'Không có mô tả',
                        style: const TextStyle(color: Colors.black54),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Chip(
                            backgroundColor: _sentimentColor(label).withOpacity(0.2),
                            label: Text(label),
                            avatar: Icon(Icons.mood, color: _sentimentColor(label), size: 18),
                          ),
                          const Spacer(),
                          Text(
                            article['source']?['name'] ?? 'Không rõ nguồn',
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                          )
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
