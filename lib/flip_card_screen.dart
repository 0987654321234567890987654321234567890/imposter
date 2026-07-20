import 'package:flutter/material.dart';
import 'dart:math';

class FlipCard extends StatefulWidget {
  final String label;
  final String hint;
  final Color color;

  const FlipCard({
    super.key,
    required this.label,
    required this.hint,
    required this.color,
  });

  @override
  State<FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<FlipCard>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Widget _buildFace(String label, String hint, Color color) {
    double fSize = 30;
    Color c = Colors.black;
    Color bc = Colors.white;
    FontWeight fw = FontWeight.bold;

    if (label == 'TAP TO REVEAL') {
      fSize = 40;
      fw = FontWeight.w900;
      bc = Colors.transparent;
    } else if (label == 'IMPOSTER') {
      fSize = 35;
      c = const Color.fromARGB(255, 230, 26, 26);
      fw = FontWeight.w900;
    }

    return Container(
      width: 220,
      height: 320,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bc,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c, fontSize: fSize, fontWeight: fw),
                ),
              ),
              if (label == 'IMPOSTER') ...[
                const SizedBox(height: 8),
                Text(
                  'Hint: $hint',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: fw,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => animationController.forward(),
      onTapUp: (details) => animationController.reverse(),
      onTapCancel: () => animationController.reverse(),
      child: AnimatedBuilder(
        animation: animationController,
        builder: (context, child) {
          final angle = animationController.value * pi;
          final isFront = angle < pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: isFront
                ? _buildFace('TAP TO REVEAL', '', widget.color)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildFace(widget.label, widget.hint, widget.color),
                  ),
          );
        },
      ),
    );
  }
}
