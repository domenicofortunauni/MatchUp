import 'package:flutter/material.dart';

class PrenotazioneActionButton extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;
  final IconData? icon;
  final VoidCallback? onTap;
  final Color? borderColor;

  const PrenotazioneActionButton({
    required this.label,
    required this.bgColor,
    required this.textColor,
    this.icon,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: borderColor != null ? Border.all(color: borderColor!) : null,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
          ],
          Text( label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
    return onTap == null ? content : InkWell(borderRadius: BorderRadius.circular(20), onTap: onTap, child: content,);
  }
}
