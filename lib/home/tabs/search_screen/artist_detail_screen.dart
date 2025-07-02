import 'package:booking_app/screens/book_services/choose_service_screen.dart';
import 'package:booking_app/widgets/colors.dart';
import 'package:booking_app/widgets/custom_loading.dart';
import 'package:flutter/material.dart';

import '../../../screens/profiles/profiles_screen.dart';
import '../../../widgets/custom_appbar.dart';

class ArtistDetailScreen extends StatefulWidget {
  final String name;
  final String imagePath;

  const ArtistDetailScreen({
    Key? key,
    required this.name,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<ArtistDetailScreen> createState() => _ArtistDetailScreenState();
}

class _ArtistDetailScreenState extends State<ArtistDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: NestedScrollView(
        headerSliverBuilder: (context, innerIsScrolled) => [
          CustomSliverAppBar(
            backgroundColor: myPrimaryColor,
            onProfileTap: () {
              loadingScreen(context, () => ProfilesScreen());
            },
          ),
        ],
        body: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 70),
              child: Column(
                children: [
                  _buildSubHeader(context),
                  const SizedBox(height: 12),
                  _buildArtistInfoContainer(),
                  const SizedBox(height: 12),
                  _buildPortfolioContainer(),
                  const SizedBox(height: 12),
                  _buildReviewContainer(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBookButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubHeader(BuildContext context) {
    return Container(
      color: myPrimaryColor,
      padding: const EdgeInsets.symmetric(vertical: 15),
      width: double.infinity,
      child: const Center(
        child: Text(
          'Makeup Artist Profile',
          style: TextStyle(
            fontSize: 20,
            fontFamily: "JacquesFrancois",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildArtistInfoContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildArtistInfo(),
    );
  }

  Widget _buildArtistInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Padding(
            padding: EdgeInsets.only(right: 8.0, top: 2),
            child: Icon(Icons.arrow_back_ios, size: 18),
          ),
        ),

        // Thông tin artist
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 4.0, right: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Experience: 5 years',
                    style:
                        TextStyle(fontFamily: "JacquesFrancois", fontSize: 13)),
                const SizedBox(height: 4),
                const Text('Work location: Los Angeles, CA, USA',
                    style:
                        TextStyle(fontFamily: "JacquesFrancois", fontSize: 13)),
                const SizedBox(height: 4),
                const Text(
                    'Makeup style: Natural, Bridal, Gala, Stage, Yearbook',
                    style:
                        TextStyle(fontFamily: "JacquesFrancois", fontSize: 13)),
                const SizedBox(height: 8),
                const Text(
                  'More information >',
                  style: TextStyle(color: Colors.purple),
                ),
              ],
            ),
          ),
        ),

        // Ảnh + Rating + Favorite
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '(4.6/5.0)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 2),
            const Row(
              children: [
                Icon(Icons.star, size: 12, color: Colors.amber),
                Icon(Icons.star, size: 12, color: Colors.amber),
                Icon(Icons.star, size: 12, color: Colors.amber),
                Icon(Icons.star, size: 12, color: Colors.amber),
                Icon(Icons.star_half, size: 12, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              '(347)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.favorite_border, size: 20),
          ],
        ),
      ],
    );
  }

  Widget _buildPortfolioContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildPortfolioSection(),
    );
  }

  Widget _buildPortfolioSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.name}\'s Portfolio',
          style: const TextStyle(
            fontSize: 16,
            fontFamily: "JacquesFrancois",
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 4),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                width: 80,
                height: 100,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: AssetImage('assets/images/model_makeup.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReviewContainer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildReviewsSection(),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.name}\'s Review',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildReviewItem('Phuong Le', 'March 3, 2023'),
        _buildReviewItem('Quynh Trang', 'February 5, 2023'),
        _buildReviewItem('Van Tien', 'February 2, 2023'),
      ],
    );
  }

  Widget _buildReviewItem(String reviewerName, String date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reviewerName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingRow('Friendliness', 5),
                _buildRatingRow('Timeliness', 5),
                _buildRatingRow('Service Quality', 5),
                _buildRatingRow('Quality', 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingRow(String label, int rating) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
        const Spacer(),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              Icons.star,
              size: 12,
              color: index < rating ? Colors.amber : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton() {
    return GestureDetector(
      onTap: () {
        loadingScreen(context, () => ChooseServiceScreen());
      },
      child: Container(
        height: 60,
        color: Colors.grey[700],
        alignment: Alignment.center,
        child: Text(
          'BOOK WITH ${widget.name} • •',
          style: const TextStyle(
            color: Colors.white,
            fontFamily: "JacquesFrancois",
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
