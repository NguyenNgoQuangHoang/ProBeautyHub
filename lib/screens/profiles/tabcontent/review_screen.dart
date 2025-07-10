import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../models/review_model.dart';
import '../../../models/user_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/custom_review_item.dart';
import '../../../services/feedback_api_service.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final FeedbackApiService _feedbackApiService = FeedbackApiService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Review> reviews = [];
  bool _isLoading = true;
  String? _error;
  double _averageRating = 0.0;
  Map<int, int> _ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
  int _totalReviews = 0;
  String? _userId; // Lưu trữ userId

  List<Review> _filteredReviews = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _getUserIdAndLoadFeedbacks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Lấy userId từ AuthProvider hoặc SharedPreferences và sau đó tải feedbacks
  Future<void> _getUserIdAndLoadFeedbacks() async {
    try {
      // Thử lấy từ SharedPreferences trước - an toàn hơn
      String? userId = await _getUserIdFromPrefs();
      
      // Chỉ thử lấy từ AuthProvider nếu không tìm thấy từ SharedPreferences
      if (userId == null || userId.isEmpty) {
        try {
          // Bọc trong try-catch riêng để xử lý lỗi Provider không tìm thấy
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          if (authProvider.currentUser?.id != null && authProvider.currentUser!.id!.isNotEmpty) {
            userId = authProvider.currentUser!.id;
            print('Found user ID from AuthProvider: $userId');
          }
        } catch (providerError) {
          print('Cannot access AuthProvider: $providerError');
          // Không làm gì, tiếp tục với userId từ SharedPreferences hoặc null
        }
      }

      if (mounted) {
        setState(() {
          _userId = userId;
        });
      }
      
      print('Using user ID for loading feedbacks: $_userId');
      await _loadFeedbacks();
    } catch (e) {
      print('Error getting user ID: $e');
      // Vẫn tải feedbacks với ID null hoặc hardcode để không bị lỗi UI
      await _loadFeedbacks();
    }
  }

  Future<String?> _getUserIdFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Thử lấy từ các khóa phổ biến
      final userId = prefs.getString('user_id') ?? 
                   prefs.getString('userId') ?? 
                   prefs.getString('id') ??
                   prefs.getString('user_data');
      
      if (userId != null && userId.isNotEmpty) {
        if (userId.startsWith('{')) {
          // Có thể là JSON string, thử parse ra
          try {
            final Map<String, dynamic> userData = jsonDecode(userId);
            final extractedId = userData['id'];
            if (extractedId != null) {
              print('Found user ID from JSON: $extractedId');
              return extractedId.toString();
            }
          } catch (e) {
            print('Error parsing user data JSON: $e');
          }
        } else {
          print('Found user ID: $userId');
          return userId;
        }
      } else {
        print('User ID not found in SharedPreferences');
      }
      
      return null;
    } catch (e) {
      print('Error getting user ID from prefs: $e');
      return null;
    }
  }

  Future<void> _loadFeedbacks() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      print('Loading feedbacks...');
      // Sử dụng userId đã lấy được, nếu không có thì dùng ID mặc định
      final String artistIdToUse = _userId ?? "df340cc4-d200-401e-ba16-0084bb285456";
      print('Using artist ID for feedback: $artistIdToUse');
      
      // Thêm thông tin debug cho request
      print('Sending feedback request with artistId: $artistIdToUse');
      
      final result = await _feedbackApiService.getFeedback(
        artistId: artistIdToUse,
      );
      
      print('Feedback result: $result');
      if (result['data'] != null) {
        print('Feedback data structure: ${result['data'].runtimeType}');
        if (result['data'] is Map) {
          print('Feedback data keys: ${(result['data'] as Map).keys.toList()}');
          if ((result['data'] as Map).containsKey('feedbackDTOs')) {
            print('Found feedbackDTOs: ${result['data']['feedbackDTOs'].length} items');
          }
        }
      }
      
      if (result['success']) {
        final data = result['data'];
        List<dynamic> feedbacks = [];
        
        // Handle different response structures based on API response
        if (data is Map<String, dynamic>) {
          // Cấu trúc mới từ API trả về
          if (data.containsKey('feedbackDTOs')) {
            feedbacks = data['feedbackDTOs'] ?? [];
          } 
          // Các cấu trúc dự phòng khác
          else if (data.containsKey('feedbacks')) {
            feedbacks = data['feedbacks'] ?? [];
          } else if (data.containsKey('data')) {
            feedbacks = data['data'] ?? [];
          } else if (data.containsKey('items')) {
            feedbacks = data['items'] ?? [];
          }
        } else if (data is List) {
          feedbacks = data;
        }

        _processFeedbacks(feedbacks);
        
        if (mounted) {
          setState(() {
            _filteredReviews = reviews; // Initialize filtered reviews
            _isLoading = false;
          });
        }
      } else {
        // Kiểm tra xem có thông báo lỗi chi tiết từ API không
        String errorMessage = 'Có lỗi xảy ra khi tải đánh giá';
        
        if (result['data'] is Map && result['data']['errorMessage'] != null) {
          errorMessage = result['data']['errorMessage'];
        } else if (result['error'] != null) {
          errorMessage = result['error'];
        }
        
        print('Feedback error: $errorMessage');
        
        if (mounted) {
          setState(() {
            _error = errorMessage;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Exception in _loadFeedbacks: $e');
      if (mounted) {
        setState(() {
          _error = 'Có lỗi xảy ra: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _processFeedbacks(List<dynamic> feedbacks) {
    reviews.clear();
    _ratingCounts = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    
    double totalRating = 0.0;
    _totalReviews = feedbacks.length;
    
    for (var feedback in feedbacks) {
      // Cập nhật mapping theo cấu trúc API
      final rating = _parseRating(feedback['rating'] ?? 0);
      final userName = feedback['userName'] ?? 'Người dùng';
      final comment = feedback['content'] ?? '';
      // Dữ liệu feedback có thể không có createdAt, sử dụng DateTime.now() làm mặc định
      final date = _formatDate(feedback['createdAt'] ?? DateTime.now().toString());
      
      reviews.add(Review(
        userName: userName,
        date: date,
        rating: rating,
        comment: comment,
      ));
      
      totalRating += rating;
      _ratingCounts[rating] = (_ratingCounts[rating] ?? 0) + 1;
    }
    
    _averageRating = _totalReviews > 0 ? totalRating / _totalReviews : 0.0;
    _filteredReviews = reviews; // Initialize filtered reviews
  }

  int _parseRating(dynamic rating) {
    if (rating == null) return 5;
    if (rating is int) return rating.clamp(1, 5);
    if (rating is double) return rating.round().clamp(1, 5);
    if (rating is String) {
      try {
        return double.parse(rating).round().clamp(1, 5);
      } catch (e) {
        return 5;
      }
    }
    return 5;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}-${date.month}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  Future<void> _refreshFeedbacks() async {
    // Khi làm mới, cố gắng lấy lại userId để đảm bảo đúng người dùng hiện tại
    await _getUserIdAndLoadFeedbacks();
  }

  void _filterReviews() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredReviews = reviews;
      } else {
        _filteredReviews = reviews.where((review) {
          final comment = review.comment.toLowerCase();
          final userName = review.userName.toLowerCase();
          final query = _searchQuery.toLowerCase();
          
          return comment.contains(query) || userName.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Đánh giá'),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Đang tải đánh giá...',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Đánh giá'),
          centerTitle: true,
        ),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Lỗi',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _refreshFeedbacks,
                child: Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Đánh giá'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshFeedbacks,
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refreshFeedbacks,
        child: Column(
          children: [
            // Overall rating section
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Large rating number
                  Text(
                    _averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Star rating visualization
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRatingRow(5, _getRatingRatio(5)),
                        _buildRatingRow(4, _getRatingRatio(4)),
                        _buildRatingRow(3, _getRatingRatio(3)),
                        _buildRatingRow(2, _getRatingRatio(2)),
                        _buildRatingRow(1, _getRatingRatio(1)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Total reviews count
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  RatingBar.builder(
                    initialRating: _averageRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemSize: 15,
                    ignoreGestures: true,
                    itemBuilder: (context, _) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {},
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$_totalReviews đánh giá',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Search and filter section
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  // Search box
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Tìm kiếm đánh giá...',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                          _filterReviews();
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Filter buttons
                  _buildFilterButton('Khu vực'),
                  const SizedBox(width: 10),
                  _buildFilterButton('Post'),
                ],
              ),
            ),
            // Reviews list
            Expanded(
              child: _filteredReviews.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rate_review, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty ? 'Chưa có đánh giá' : 'Không tìm thấy kết quả',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            _searchQuery.isEmpty 
                                ? 'Hiện tại chưa có đánh giá nào'
                                : 'Thử từ khóa khác để tìm kiếm',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredReviews.length,
                      itemBuilder: (context, index) {
                        return ReviewItem(review: _filteredReviews[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  double _getRatingRatio(int rating) {
    if (_totalReviews == 0) return 0.0;
    return (_ratingCounts[rating] ?? 0) / _totalReviews;
  }

  Widget _buildRatingRow(int stars, double fillRatio) {
    return Row(
      children: [
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < stars ? Icons.star : Icons.star_border,
              color: Colors.amber,
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fillRatio,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 12),
          ),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
    );
  }
}
