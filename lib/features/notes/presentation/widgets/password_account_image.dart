import 'package:flutter/material.dart';
import 'package:pocket_notes/features/notes/data/models/password_entry.dart';

class PasswordAccountImage extends StatelessWidget {
  const PasswordAccountImage({
    super.key,
    required this.title,
    required this.imageUrl,
    this.size = 44,
  });

  final String title;
  final String imageUrl;
  final double size;

  static const List<Color> _colors = [
    Color(0xFF1769FF),
    Color(0xFFE1306C),
    Color(0xFF7B61FF),
    Color(0xFF111111),
    Color(0xFF0A66C2),
    Color(0xFF16A34A),
  ];

  @override
  Widget build(BuildContext context) {
    final fallback = _PasswordLetterImage(title: title, size: size);
    final imageUri = PasswordEntry(imageUrl: imageUrl).displayImageUri;
    if (imageUri == null) return fallback;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUri.toString(),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return fallback;
        },
      ),
    );
  }
}

class _PasswordLetterImage extends StatelessWidget {
  const _PasswordLetterImage({required this.title, required this.size});

  final String title;
  final double size;

  @override
  Widget build(BuildContext context) {
    final label = title.trim().isEmpty ? '?' : title.trim().characters.first;
    final color =
        PasswordAccountImage._colors[title.hashCode.abs() %
            PasswordAccountImage._colors.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
