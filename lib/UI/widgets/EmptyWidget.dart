import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String text;
  final String? subText;
  final IconData icon;

  const EmptyWidget({
    Key? key,
    required this.text,
    this.subText,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 40, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 8),
        Text(text, textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (subText != null)
          Text(
            subText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 14,
            ),
          ),
      ],
    );
  }
}
