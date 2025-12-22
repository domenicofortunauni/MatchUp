import 'package:flutter/material.dart';
import '../../../model/objects/SfidaModel.dart';
import '../../behaviors/AppLocalizations.dart';

class SfidaCard extends StatelessWidget {
  final SfidaModel sfida;
  final String? labelButton;
  final VoidCallback? onPressed;
  final bool showButton;
  final Color? customButtonColor;
  final String? customTitle;
  final Widget? extraWidget;
  final IconData customIcon;

  const SfidaCard({
    Key? key,
    required this.sfida,
    this.labelButton,
    this.onPressed,
    this.showButton = true,
    this.customButtonColor,
    this.customTitle,
    this.extraWidget,
    required this.customIcon,
  }) : super(key: key);

  Color _getLevelColor(String livello) {
    String l = livello.toLowerCase();
    if (l.contains("amatoriale")) return Colors.green;
    if (l.contains("dilettante")) return Colors.blue;
    if (l.contains("intermedio")) return Colors.white;
    if (l.contains("avanzato")) return Colors.red;
    return Colors.amber; //se professionista (o null :/)
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final levelColor = _getLevelColor(sfida.livello);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.grey.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 50, height: 50,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(this.customIcon, color: colorScheme.onPrimaryContainer, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  customTitle ?? sfida.challengerName,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: levelColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: levelColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.translate(sfida.livello),
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: levelColor),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.stadium_rounded, size: 16, color: colorScheme.secondary),
                              const SizedBox(width: 6),
                              Expanded(child: Text(sfida.nomeStruttura, style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.calendar_month_rounded, size: 16, color: colorScheme.secondary),
                              const SizedBox(width: 6),
                              Text(sfida.dataOra, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (extraWidget != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: extraWidget,
                )
              else if (showButton && labelButton != null) // Mostra solo se il testo esiste
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: onPressed,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: customButtonColor ?? colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                      ),
                      child: Text(labelButton!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}