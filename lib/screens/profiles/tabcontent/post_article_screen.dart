import 'package:flutter/material.dart';
import 'package:booking_app/services/post_api_service.dart';

class PostArticleScreen extends StatefulWidget {
  final Map<String, dynamic>? post;
  final bool isPreview;
  final bool loadFromApi;

  const PostArticleScreen({
    super.key,
    this.post,
    this.isPreview = false,
    this.loadFromApi = false,
  });

  @override
  State<PostArticleScreen> createState() => _PostArticleScreenState();
}

class _PostArticleScreenState extends State<PostArticleScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // API related
  final PostApiService _postApiService = PostApiService();
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.loadFromApi) {
      _loadPosts();
    }
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

  List<String> getImages(Map<String, dynamic>? post) {
    if (post != null && post['thumbnailUrl'] != null) {
      return [post['thumbnailUrl']];
    }
    return ["assets/images/content.png"];
  }

  List<String> getTags(Map<String, dynamic>? post) {
    if (post != null && post['tags'] != null) {
      String tagsString = post['tags'].toString();
      return tagsString.split(',').map((tag) => tag.trim()).toList();
    }
    return [];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loadFromApi) {
      if (_isLoading) {
        return _buildLoadingState();
      }

      if (_errorMessage != null) {
        return _buildErrorState();
      }

      if (_posts.isEmpty) {
        return _buildEmptyState();
      }

      // Hiển thị tất cả posts
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _posts.length,
        separatorBuilder: (context, index) => const Divider(
          height: 32,
          thickness: 1,
          color: Colors.grey,
        ),
        itemBuilder: (context, index) {
          final post = _posts[index];
          return _buildSinglePost(post);
        },
      );
    }

    // Hiển thị single post nếu có data hoặc default content
    return _buildSinglePost(widget.post);
  }

  Widget _buildSinglePost(Map<String, dynamic>? post) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildImageSection(post),
        if (!widget.isPreview) _buildActionsRow(),
        _buildContentSection(post),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: widget.isPreview ? 200 : 300,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      height: widget.isPreview ? 200 : 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadPosts,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: widget.isPreview ? 200 : 300,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'Chưa có bài viết nào',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(Map<String, dynamic>? post) {
    final images = getImages(post);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          height: widget.isPreview ? 200 : 300,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = images[index];

              if (imageUrl.startsWith('http')) {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) {
                        print('Error loading image: $exception');
                      },
                    ),
                  ),
                );
              } else {
                return Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }
            },
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                images.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  height: 8,
                  width: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index ? Colors.blue : Colors.white,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: Row(
        children: const [
          Icon(Icons.favorite, color: Colors.red),
          SizedBox(width: 15),
          Icon(Icons.chat_bubble_outline),
          SizedBox(width: 15),
          Icon(Icons.send),
          Spacer(),
          Icon(Icons.bookmark_border),
        ],
      ),
    );
  }

  Widget _buildContentSection(Map<String, dynamic>? post) {
    final tags = getTags(post);

    if (post == null) {
      return _buildDefaultContent();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Author header with avatar and name
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: post['authorAvatarUrl'] != null
                    ? NetworkImage(post['authorAvatarUrl'])
                    : null,
                child: post['authorAvatarUrl'] == null
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post['authorName'] ?? 'Unknown',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _formatDate(post['createdAt']),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  // Handle more options
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Title
          if (post['title'] != null && post['title'].toString().isNotEmpty)
            Text(
              post['title'].toString(),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

          const SizedBox(height: 8),

          // Content
          if (post['content'] != null && post['content'].toString().isNotEmpty)
            Text(
              post['content'].toString(),
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 15,
                height: 1.4,
              ),
              maxLines: widget.isPreview ? 3 : null,
              overflow: widget.isPreview ? TextOverflow.ellipsis : null,
            ),

          const SizedBox(height: 12),

          // Tags
          if (tags.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: tags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ))
                  .toList(),
            ),

          const SizedBox(height: 16),

          // Service Option (if available)
          if (post['serviceOptionId'] != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.business_center,
                      color: Colors.orange[700], size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Dịch vụ liên quan',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Likes count
          const Text(
            '74 likes',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('74 likes', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                    text: 'Dimx: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: 'Beautiful'),
              ],
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                    text: 'Chang: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: 'Chưa đủ wow!'),
              ],
            ),
          ),
          const SizedBox(height: 2),
          RichText(
            text: const TextSpan(
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                    text: 'Demi: ',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(
                  text:
                      'Bài makeup này thực sự cuốn lắm, tông màu hài hòa, kỹ thuật blend',
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          const Text('2 July 2023 · View translation',
              style: TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
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
