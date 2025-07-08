import 'package:flutter/material.dart';
import 'package:booking_app/services/post_api_service.dart';
import 'create_post_screen.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final PostApiService _postApiService = PostApiService();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final result = await _postApiService.getPosts();

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        // Handle API response format: { "posts": [...], "isSuccess": true }
        if (data is Map && data['isSuccess'] == true && data['posts'] != null) {
          setState(() {
            _posts = List<Map<String, dynamic>>.from(data['posts']);
            _isLoading = false;
          });
        } else if (data is List) {
          setState(() {
            _posts = List<Map<String, dynamic>>.from(data);
            _isLoading = false;
          });
        } else {
          setState(() {
            _posts = [];
            _isLoading = false;
          });
        }

        print('Loaded ${_posts.length} posts');
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Không thể tải danh sách bài viết';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Lỗi khi tải dữ liệu: $e';
        _isLoading = false;
      });
      print('Error loading posts: $e');
    }
  }

  Future<void> _onCreatePost() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );

    if (result == true) {
      _loadPosts(); // Refresh danh sách sau khi tạo mới
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPosts,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreatePost,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey),
        ),
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'Lỗi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: "JacquesFrancois",
              ),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontFamily: "JacquesFrancois",
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPosts,
              child: Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Trống',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: "JacquesFrancois",
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hiện tại chưa có bài viết nào',
              style: TextStyle(
                color: Colors.grey,
                fontFamily: "JacquesFrancois",
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPosts,
      child: ListView.builder(
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostItem(post);
        },
      ),
    );
  }

  Widget _buildPostItem(dynamic post) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header với avatar và tên
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: post['author']?['avatar'] != null
                      ? NetworkImage(post['author']['avatar'])
                      : null,
                  child: post['author']?['avatar'] == null
                      ? Icon(Icons.person)
                      : null,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['author']?['title'] ?? 'Không rõ tên',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _formatDate(post['createdAt']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Tiêu đề
            if (post['title'] != null && post['title'].isNotEmpty)
              Text(
                post['title'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  fontFamily: "JacquesFrancois",
                ),
              ),

            SizedBox(height: 8),

            // Nội dung
            if (post['content'] != null && post['content'].isNotEmpty)
              Text(
                post['content'],
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: "JacquesFrancois",
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

            SizedBox(height: 12),

            // Ảnh thumbnail
            if (post['thumbnail'] != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  post['thumbnail'],
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
              ),

            SizedBox(height: 12),

            // Tags
            if (post['tags'] != null && post['tags'].isNotEmpty)
              Wrap(
                spacing: 8,
                children: _parseTags(post['tags']).map<Widget>((tag) {
                  return Chip(
                    label: Text(
                      tag.toString(),
                      style: TextStyle(fontSize: 12),
                    ),
                    backgroundColor: Colors.blue[100],
                  );
                }).toList(),
              ),

            SizedBox(height: 8),

            // Thông tin dịch vụ liên quan
            if (post['serviceOptions'] != null &&
                post['serviceOptions'].isNotEmpty)
              Text(
                'Dịch vụ: ${(post['serviceOptions'] as List).map((s) => s['name']).join(', ')}',
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];

    if (tags is List) {
      return tags
          .map((tag) => tag.toString().trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    if (tags is String) {
      return tags
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();
    }

    return [];
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';

    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return '${date.day}/${date.month}/${date.year}';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    } catch (e) {
      return dateStr;
    }
  }
}
