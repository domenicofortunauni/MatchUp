import 'package:flutter/material.dart';
import '../../behaviors/AppLocalizations.dart';
import '../aggiungi_set_partita.dart';

class SetScoreList extends StatelessWidget {
  final List<SetInputControllers> controllers;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;

  const SetScoreList({
    super.key,
    required this.controllers,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: controllers.asMap().entries.map((entry) {
        //entry.key = indice, entry.value = coppia di controller
        int idx = entry.key;
        SetInputControllers controllers = entry.value;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Center(
                  child: Text("${idx + 1}°", style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: aggiungi_set_partita(
                    me: controllers.me,
                    opponent: controllers.opponent,
                    validator: (val) {
                      if (idx == 0 && (val == null || val.isEmpty)) {
                        return AppLocalizations.of(context)!.translate(
                            "Obbligatorio!");
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 40,
                child: idx > 0
                    ? IconButton(icon: const Icon(
                    Icons.remove_circle_outline, color: Colors.red),
                  onPressed: () => onRemove(idx),)
                    : const SizedBox(),
              )
            ],
          ),
        );
      }).toList(),
    );
  }
}

class SetInputControllers {
  final TextEditingController me = TextEditingController();
  final TextEditingController opponent = TextEditingController();
}
