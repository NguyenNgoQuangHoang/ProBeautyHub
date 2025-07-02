import 'package:flutter/material.dart';

class InfoRow extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String title;

  const InfoRow({
    super.key,
    this.icon,
    this.label = '',
    this.title = '',
  });

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final screenWidth = MediaQuery.of(context).size.width;

    double containerWidth = orientation == Orientation.portrait
        ? screenWidth * 0.55
        : screenWidth * 0.45;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) Icon(icon),
              if (icon != null) const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "JacquesFrancois",
                ),
              ),
            ],
          ),
          Container(
            width: containerWidth,
            alignment: Alignment.centerLeft,
            child: Flexible(
              fit: FlexFit.loose,
              child: Text(
                title,
                maxLines: 5,
                softWrap: true,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: "JacquesFrancois",
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
