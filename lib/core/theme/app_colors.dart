import 'package:flutter/material.dart';

// Primary brand color from Foodies1
const Color appColor = Color(0xFFFF8B2C);

BoxDecoration primaryGradientButton({double radius = 10}) {
  return BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFF9E25), Color(0xFFFF7F30)],
    ),
  );
}

BoxDecoration roundedPrimaryGradientButton({double radius = 50}) {
  return BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(radius)),
    gradient: const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFF9E25), Color(0xFFFF7F30)],
    ),
  );
}

