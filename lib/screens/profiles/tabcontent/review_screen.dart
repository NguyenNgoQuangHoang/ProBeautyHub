import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../models/review_model.dart';
import '../../../widgets/custom_review_item.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Review> reviews = [
    Review(
      userName: "Hoàng",
      date: "20-5-2025",
      rating: 5,
      comment:
          "Dịch vụ makeup ở đây thật tuyệt vời! Chuyên viên tay nghề cao, tư vấn tận tình, makeup đẹp tự nhiên, lâu trôi. Rất hài lòng và sẽ quay lại! ❤️",
    ),
    Review(
      userName: "Hoàng",
      date: "20-5-2025",
      rating: 4,
      comment:
          "Dịch vụ makeup ở đây thật tuyệt vời! Chuyên viên tay nghề cao, tư vấn tận tình, makeup đẹp tự nhiên, lâu trôi. Rất hài lòng và sẽ quay lại! ❤️",
    ),
    Review(
      userName: "Hoàng",
      date: "20-5-2025",
      rating: 3,
      comment:
          "Dịch vụ makeup ở đây thật tuyệt vời! Chuyên viên tay nghề cao, tư vấn tận tình, makeup đẹp tự nhiên, lâu trôi. Rất hài lòng và sẽ quay lại! ❤️",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Overall rating section
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Large rating number
                const Text(
                  '4.5',
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
                      _buildRatingRow(5, 1.0),
                      _buildRatingRow(4, 0.8),
                      _buildRatingRow(3, 0.6),
                      _buildRatingRow(2, 0.3),
                      _buildRatingRow(1, 0.1),
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
                  initialRating: 4.5,
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
                  '2,256,896',
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
                        hintText: 'Search',
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
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
            child: ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return ReviewItem(review: reviews[index]);
              },
            ),
          ),
        ],
      ),
    );
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
