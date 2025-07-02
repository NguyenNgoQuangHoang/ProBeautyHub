import 'package:flutter/material.dart';

class ListPostScreen extends StatelessWidget {
  const ListPostScreen({super.key});

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
          'Post',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add, color: Colors.black),
          ),
        ],
      ),
      body: ListView(
        children: [
          _buildPostItem(
            context,
            avatar: 'assets/images/profile.png',
            username: 'Demi',
            images: [
              'assets/images/content.png',
              'assets/images/model_makeup.png',
            ],
            likes: 74,
            comments: const [
              {'user': 'Dimx', 'text': 'Beautiful'},
              {'user': 'Chang', 'text': 'Chưa đủ wow!'},
            ],
            caption:
                'Bài makeup này thực sự cuốn hút, tông màu hài hòa, kỹ thuật blend quá đỉnh!',
            date: 'June 7, 2021',
          ),
          const SizedBox(height: 16),
          _buildPostItem(
            context,
            avatar: 'assets/images/profile.png',
            username: 'Demi',
            images: [
              'assets/images/model_makeup.png',
              'assets/images/content.png',
            ],
            likes: 56,
            comments: const [
              {'user': 'Nam', 'text': 'Blend đỉnh thật!'},
            ],
            caption: 'Lớp nền cực mịn luôn 😍',
            date: 'May 20, 2021',
          ),
        ],
      ),
    );
  }

  Widget _buildPostItem(
    BuildContext context, {
    required String avatar,
    required String username,
    required List<String> images,
    required int likes,
    required List<Map<String, String>> comments,
    required String caption,
    required String date,
  }) {
    final PageController pageController = PageController();
    final ValueNotifier<int> currentPage = ValueNotifier<int>(0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                      backgroundImage: AssetImage(avatar),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                username,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  fontFamily: "JacquesFrancois",
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {},
              ),
            ],
          ),
        ),

        // Image Carousel
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: pageController,
            itemCount: images.length,
            onPageChanged: (index) => currentPage.value = index,
            itemBuilder: (context, index) {
              return Image.asset(
                images[index],
                width: double.infinity,
                fit: BoxFit.cover,
              );
            },
          ),
        ),

        // Dots Indicator
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Center(
            child: ValueListenableBuilder<int>(
              valueListenable: currentPage,
              builder: (context, value, _) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(images.length, (index) {
                    return Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: value == index ? Colors.blue : Colors.grey,
                      ),
                    );
                  }),
                );
              },
            ),
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

        // Likes
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '$likes likes',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        // Comments
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var c in comments)
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    children: [
                      TextSpan(
                        text: '${c['user']}: ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: c['text']),
                    ],
                  ),
                ),
              RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black),
                  children: [
                    TextSpan(
                      text: '$username: ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(text: caption),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Date
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Text(
            '$date · View translation',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
