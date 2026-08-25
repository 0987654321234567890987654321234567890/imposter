import 'package:flutter/material.dart';
import 'dart:math';

import 'package:imposter/main.dart';

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

  Widget _buildFrontFace(Color color) {
    final textColor = _textColorForBackground(color);

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
      child: Text(
        'TAP TO REVEAL',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: textColor,
          fontSize: 40,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildBackFace(
    BuildContext context,
    String label,
    String hint,
    Color color,
  ) {
    final theme = Theme.of(context);
    final bc = theme.colorScheme.surface;

    final bool isImposter = label == 'IMPOSTER';
    final Color textColor = isImposter ? accentRed : bgCharcoal;

    final Color hintColor = _textColorForBackground(color);

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
                constraints: const BoxConstraints(maxWidth: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: bc,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: isImposter ? 25 : 30,
                    fontWeight: isImposter ? FontWeight.w900 : FontWeight.bold,
                  ),
                ),
              ),
              if (isImposter) ...[
                const SizedBox(height: 8),
                Text(
                  'Hint: $hint',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: hintColor,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
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
                ? _buildFrontFace(widget.color)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBackFace(
                      context,
                      widget.label,
                      widget.hint,
                      widget.color,
                    ),
                  ),
          );
        },
      ),
    );
  }
}

Color _textColorForBackground(Color background) {
  return background.computeLuminance() > 0.5 ? bgCharcoal : Colors.white;
}
