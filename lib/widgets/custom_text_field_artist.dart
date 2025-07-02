import 'package:booking_app/widgets/colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormFieldArtist extends StatelessWidget {
  final String hintText;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Icon? suffixIcon;
  final bool readOnly;
  final VoidCallback? onTap;
  final int maxLines;
  final TextEditingController? controller;

  const CustomTextFormFieldArtist({
    super.key,
    required this.hintText,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    this.readOnly = false,
    this.onTap,
    this.maxLines = 1,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      maxLines: maxLines,
      style: const TextStyle(
        fontFamily: 'JacquesFrancois',
        fontSize: 16,
        color: Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
            color: Colors.black, fontFamily: "JacquesFrancois", fontSize: 14),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: mySecondaryColor,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
