import 'package:flutter/material.dart';

class MascotCharacter extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const MascotCharacter({
    super.key,
    this.size = 120,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.1),
        child: Image.asset(
          'assets/images/mascot.png', // Updated path
          width: size,
          height: size,
          fit: fit,
          errorBuilder: (context, error, stackTrace) {
            // Fallback widget if image fails to load
            return _buildFallbackMascot();
          },
        ),
      ),
    );
  }

  Widget _buildFallbackMascot() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFD32F2F),
        borderRadius: BorderRadius.circular(size * 0.1),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Icon(Icons.explore, size: size * 0.6, color: Colors.white),
    );
  }
}
