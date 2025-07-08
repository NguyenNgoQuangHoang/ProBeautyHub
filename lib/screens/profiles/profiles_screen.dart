// lib/screens/profiles_screen.dart
import 'package:booking_app/screens/profiles/tabcontent/review_screen.dart';
import 'package:flutter/material.dart';
import 'tabcontent/post_article_screen.dart';
import 'profile_header.dart';
import 'tabcontent/services/service_list_screen.dart';

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({super.key});

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: const Text(
            'Huynh.James',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          ProfileHeader(),

          // Tab bar
          TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            indicatorColor: Colors.purple,
            tabs: const [
              Tab(text: 'Bài viết'),
              Tab(text: 'Dịch vụ'),
              Tab(text: 'Đánh giá'),
            ],
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                const SingleChildScrollView(
                  child: PostArticleScreen(
                    loadFromApi: true,
                    isPreview: false,
                  ),
                ),
                ServiceListScreen(),
                ReviewScreen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
