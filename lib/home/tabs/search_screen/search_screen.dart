import 'package:flutter/material.dart';
import '../../../widgets/colors.dart';
import '../../../widgets/custom_artist.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String selectedLocation = '';
  bool isDropdownOpen = false;
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  int selectedTab = 0;

  final List<Map<String, String>> artists = [
    {
      'name': 'Alexander',
      'rating': '4.8',
      'reviews': '347',
      'image': 'assets/images/model_makeup.png',
    },
    {
      'name': 'William',
      'rating': '4.6',
      'reviews': '58',
      'image': 'assets/images/model_makeup.png',
    },
    {
      'name': 'Lucas',
      'rating': '5.0',
      'reviews': '220',
      'image': 'assets/images/model_makeup.png',
    },
    {
      'name': 'Sophia',
      'rating': '4.9',
      'reviews': '980',
      'image': 'assets/images/model_makeup.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _buildHeader(),
            _buildLocationSelector(),
            if (isDropdownOpen) _buildLocationDropdownContent(),
            _buildSearchBar(),
            _buildTabBar(),
            const SizedBox(height: 10),
            _buildArtistGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      child: const Center(
        child: Text(
          'Browse a makeup artist',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: "AbhayaLibre",
            fontSize: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Container(
      color: myPrimaryColor,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () => setState(() => isDropdownOpen = !isDropdownOpen),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              selectedLocation.isEmpty ? 'Select location' : selectedLocation,
              style:
                  const TextStyle(fontSize: 14, fontFamily: "JacquesFrancois"),
            ),
            Icon(
              isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdownContent() {
    return Container(
      width: double.infinity,
      color: myPrimaryColor,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                minimumSize: const Size(313, 35),
              ),
              child: const Text(
                'ENABLE GPS SERVICE',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('ENTER YOUR ADDRESS', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 5),
          TextField(
            controller: _addressController,
            decoration: const InputDecoration(
              hintText: 'Start enter your address',
              hintStyle: TextStyle(fontSize: 13, color: Colors.black45),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black45),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedLocation = 'Da Nang';
                  isDropdownOpen = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                minimumSize: const Size(313, 35),
              ),
              child: const Text(
                'FIND SERVICES',
                style: TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Start enter your artist',
          border: InputBorder.none,
          icon: Icon(Icons.search),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildTabItem("🔥 Hot", 0),
        _buildTabItem("Favorite", 1),
        _buildTabItem("Price", 2),
      ],
    );
  }

  Widget _buildTabItem(String label, int index) {
    final bool isSelected = selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => selectedTab = index),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontFamily: "JacquesFrancois",
              color: isSelected ? Colors.black : Colors.grey,
            ),
          ),
          if (isSelected)
            Container(
              height: 2,
              width: 20,
              margin: const EdgeInsets.only(top: 4),
              color: Colors.black,
            )
        ],
      ),
    );
  }

  Widget _buildArtistGrid() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: artists.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.65,
        ),
        itemBuilder: (context, index) {
          final artist = artists[index];
          return ArtistCard(
            name: artist['name']!,
            rating: artist['rating']!,
            reviews: artist['reviews']!,
            imagePath: artist['image']!,
          );
        },
      ),
    );
  }
}
