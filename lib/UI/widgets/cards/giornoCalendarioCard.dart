import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class giornoCalendarioCard extends StatelessWidget {
  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final int eventCount;
  final VoidCallback onTap;
  final double width;
  final Color primaryColor;
  final bool isDarkMode;
  final String localeCode;

  const giornoCalendarioCard({
    Key? key,
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.eventCount,
    required this.onTap,
    required this.width,
    required this.primaryColor,
    required this.isDarkMode,
    required this.localeCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isSelected ? primaryColor : (isDarkMode ? Theme.of(context).colorScheme.secondary : Colors.grey.shade100);
    final Color borderColor = isSelected ? primaryColor : (isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300);
    final Color textColor = isSelected ? Colors.white : Colors.black;
    final String dayName = DateFormat('EEE', localeCode).format(date).toUpperCase();
    final String dayNumber = DateFormat('d', localeCode).format(date);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: width,
            height: 90,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayName,
                  style: TextStyle(
                    color: textColor.withValues(alpha: 0.7),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  dayNumber,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                if (isToday) ...[
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.translate("oggi"),
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (eventCount > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    width: 2,
                  ),
                ),
                child: Text(
                  eventCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}