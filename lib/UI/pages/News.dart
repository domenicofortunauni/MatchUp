import 'package:flutter/material.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/behaviors/gnews_service.dart';
import 'package:matchup/UI/widgets/NewsCard.dart';

class News extends StatelessWidget {
  const News({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("News")),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Notizia>>(
        future: fetchNews(), // Chiama la funzione API per ottenere le notizie
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Impossibile caricare le notizie: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            );
          }
          else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final List<Notizia> notizie = snapshot.data!;

            return RefreshIndicator(
              // Permette all'utente di aggiornare il feed tirando verso il basso
              onRefresh: () => Future.value(null), // Non supporta il refresh diretto qui, ma mantiene la UI
              child: ListView.builder(
                itemCount: notizie.length,
                itemBuilder: (context, index) {
                  return NewsCard(notizia: notizie[index]);
                },
              ),
            );
          }
          else {
            return Center(child: Text(AppLocalizations.of(context)!.translate("NoNews")));
          }
        },
      ),
    );
  }
}