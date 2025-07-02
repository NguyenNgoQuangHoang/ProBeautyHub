import 'package:flutter/material.dart';

class CustomSliverAppBar extends StatelessWidget {
  final VoidCallback? onProfileTap;
  final Color backgroundColor;

  const CustomSliverAppBar({
    Key? key,
    this.onProfileTap,
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: false,
      scrolledUnderElevation: 0,
      snap: false,
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor,
      title: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      "FLAW",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                    ),
                    Image.asset(
                      "assets/images/entypo_flower.png",
                      width: 24,
                      height: 24,
                    ),
                    Text(
                      "ESS",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        shadows: [
                          Shadow(
                            blurRadius: 10.0,
                            color: Colors.black.withOpacity(0.5),
                            offset: Offset(5.0, 5.0),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('assets/images/profile.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
