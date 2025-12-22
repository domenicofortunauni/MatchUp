import 'package:flutter/material.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class MySearchBar extends StatelessWidget {
  final TextEditingController controller;
  final void Function(String) onSearch;
  final bool enabled;
  final Color primaryColor;
  final String labelKey;
  final String hintKey;

  const MySearchBar({
    super.key,
    required this.controller,
    required this.onSearch,
    required this.primaryColor,
    this.enabled = true,
    this.labelKey = 'Cerca città',
    this.hintKey = 'es. Roma',
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.translate(labelKey),
              hintText: AppLocalizations.of(context)!.translate(hintKey),
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(22),),
              contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16,),
            ),
            onSubmitted: onSearch,
          ),
        ),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: enabled ? () => onSearch(controller.text) : null,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15,),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22),),
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
          ),
          child: Text(AppLocalizations.of(context)!.translate("Cerca"),),
        ),
      ],
    );
  }
}
