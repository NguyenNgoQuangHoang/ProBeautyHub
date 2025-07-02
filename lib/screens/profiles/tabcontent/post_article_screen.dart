import 'package:flutter/material.dart';

class PostArticleScreen extends StatefulWidget {
  const PostArticleScreen({super.key});

  @override
  State<PostArticleScreen> createState() => _PostArticleScreenState();
}

class _PostArticleScreenState extends State<PostArticleScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> images = [
    "assets/images/content.png",
    "assets/images/content.png",
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 300,
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
                      return Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(images[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
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
                          color: _currentPage == index
                              ? Colors.blue
                              : Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('74 likes',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
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
                    text: TextSpan(
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
                    text: TextSpan(
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
            ),
          ],
        ),
      ],
    );
  }
}
