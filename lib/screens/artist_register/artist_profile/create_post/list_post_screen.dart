import 'package:flutter/material.dart';
import 'create_post_screen.dart';
import 'package:booking_app/services/post_api_service.dart';

class ListPostScreen extends StatefulWidget {
  const ListPostScreen({super.key});

  @override
  State<ListPostScreen> createState() => _ListPostScreenState();
}

class _ListPostScreenState extends State<ListPostScreen> {
  final PostApiService _postApiService = PostApiService();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _postApiService.getPosts();
      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        if (data is Map && data['isSuccess'] == true && data['posts'] != null) {
          setState(() {
            _posts = List<Map<String, dynamic>>.from(data['posts']);
          });
        } else if (data is List) {
          setState(() {
            _posts = List<Map<String, dynamic>>.from(data);
          });
        }

        print('Loaded ${_posts.length} posts');
      } else {
        setState(() {
          _error = result['error'] ?? 'Lỗi không xác định';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải dữ liệu: $e';
      });
      print('Error loading posts: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Bài đăng của tôi',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreatePostScreen(),
                ),
              );

              // Refresh list if post was created
              if (result == true) {
                _loadPosts();
              }
            },
            icon: const Icon(Icons.add, color: Colors.black),
          ),
          IconButton(
            onPressed: _loadPosts,
            icon: const Icon(Icons.refresh, color: Colors.black),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải bài đăng...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              _error!,
              style: TextStyle(color: Colors.red),
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
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Chưa có bài đăng nào',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontFamily: "JacquesFrancois",
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Nhấn nút + để tạo bài đăng đầu tiên',
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
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _posts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildPostItemFromApi(context, post);
        },
      ),
    );
  }

  Widget _buildPostItemFromApi(
      BuildContext context, Map<String, dynamic> post) {
    final String authorName =
        post['authorName']?.toString() ?? 'Không rõ tác giả';
    final String authorAvatarUrl = post['authorAvatarUrl']?.toString() ?? '';
    final String title = post['title']?.toString() ?? '';
    final String content = post['content']?.toString() ?? '';
    final String thumbnailUrl = post['thumbnailUrl']?.toString() ?? '';
    final String tags = post['tags']?.toString() ?? '';
    final String postId = post['id']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.pink, const Color(0xFFDAC447)],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 15,
                      backgroundImage: authorAvatarUrl.isNotEmpty
                          ? NetworkImage(authorAvatarUrl)
                          : const AssetImage('assets/images/profile.png')
                              as ImageProvider,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        fontFamily: "JacquesFrancois",
                      ),
                    ),
                    if (title.isNotEmpty)
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontFamily: "JacquesFrancois",
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handlePostAction(value, postId, post),
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Chỉnh sửa'),
                        ],
                      ),
                    ),
                    const PopupMenuItem<String>(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Xóa', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ];
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Thumbnail image
        if (thumbnailUrl.isNotEmpty)
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.network(
              thumbnailUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey.shade200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.broken_image, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Không thể tải ảnh',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),

        // Actions
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: const [
              Icon(Icons.favorite_border, color: Colors.black),
              SizedBox(width: 16),
              Icon(Icons.mode_comment_outlined, color: Colors.black),
              SizedBox(width: 16),
              Icon(Icons.send, color: Colors.black),
              Spacer(),
              Icon(Icons.bookmark_border, color: Colors.black),
            ],
          ),
        ),

        // Content
        if (content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              content,
              style: const TextStyle(
                fontFamily: "JacquesFrancois",
              ),
            ),
          ),

        // Tags
        if (tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Wrap(
              spacing: 8,
              children: tags.split(',').map((tag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#${tag.trim()}',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontFamily: "JacquesFrancois",
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _handlePostAction(
      String action, String postId, Map<String, dynamic> post) {
    switch (action) {
      case 'edit':
        // TODO: Navigate to edit post screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Chỉnh sửa bài đăng: ${post['title']}')),
        );
        break;
      case 'delete':
        _showDeleteConfirmDialog(postId, post['title']?.toString() ?? '');
        break;
    }
  }

  void _showDeleteConfirmDialog(String postId, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc chắn muốn xóa bài đăng "$title"?'),
          actions: [
            TextButton(
              child: const Text('Hủy'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost(postId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    try {
      final result = await _postApiService.deletePost(postId);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xóa bài đăng thành công')),
        );
        _loadPosts(); // Refresh the list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Lỗi: ${result['message'] ?? 'Không xác định'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
}
