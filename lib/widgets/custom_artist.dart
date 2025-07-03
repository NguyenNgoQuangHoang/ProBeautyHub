import 'package:booking_app/widgets/colors.dart';
import 'package:flutter/material.dart';
import '../home/tabs/search_screen/artist_detail_screen.dart';

class ArtistCard extends StatelessWidget {
  final String name;
  final String rating;
  final String reviews;
  final String imagePath;

  const ArtistCard({
    super.key,
    required this.name,
    required this.rating,
    required this.reviews,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ArtistDetailScreen(
              name: name,
              imagePath: imagePath,
            ),
          ),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 70, bottom: 20),
              decoration: BoxDecoration(
                color: mySecondaryColor,
                borderRadius: BorderRadius.circular(3),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      fontFamily: "AbhayaLibre",
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: List.generate(
                          5,
                          (index) => const Icon(
                            Icons.star,
                            size: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '($rating/5.0)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '($reviews)',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Artist image
          Positioned(
            top: 0,
            left: 30,
            right: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                imagePath,
                height: 120,
                width: 120,
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Heart icon
          const Positioned(
            top: 70,
            right: 5,
            child: Icon(
              Icons.favorite_border,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
