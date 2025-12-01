import 'package:flutter/material.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import '../../../model/objects/PartitaModel.dart';
import '../cards/MatchCard.dart';
import 'noPartiteStorico.dart';

class StoricoPartiteWidget extends StatefulWidget {
  final List<Partita> partite;

  const StoricoPartiteWidget({super.key, required this.partite});

  @override
  State<StoricoPartiteWidget> createState() => _StoricoPartiteWidgetState();
}

class _StoricoPartiteWidgetState extends State<StoricoPartiteWidget> {

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
          child: Text(
            AppLocalizations.of(context)!.translate("Storico partite"),
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        // LISTA PARTITE
        if (widget.partite.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.partite.length,
            itemBuilder: (context, index) {
              return MatchCard(partita: widget.partite[index]);
            },
          )
        else
          noPartiteStorico(),
        const SizedBox(height: 10),
      ],
    );
  }
}