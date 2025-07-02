import 'package:flutter/material.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile picture and stats
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.pink,
                      const Color.fromARGB(255, 218, 196, 71)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/images/profile.png'),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatColumn('883', 'Posts'),
                    _buildStatColumn('14 000', 'Followers'),
                    _buildStatColumn('1 000', 'Following'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Bio
        Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 8.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Demi Makeup Artist',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('The best solutions for your business'),
              SizedBox(height: 4),
              Text(
                'Da Nang, Viet Nam',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('Khu vực làm việc : Ngũ Hành Sơn'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          count,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
