import 'package:flutter/material.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/widgets/cards/NewsCard.dart';
import 'package:matchup/services/gnews_service.dart';
import '../../model/objects/NotiziaModel.dart';

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
      body: FutureBuilder<List<NotiziaModel>>(
        future: fetchNews(Localizations.localeOf(context).languageCode),
        // Chiama la funzione API per ottenere le notizie con la lingua giusta!!
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  AppLocalizations.of(context)!.translate("Impossibile caricare le notizie: ") + "${snapshot.error}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                ),
              ),
            );
          }
          else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final List<NotiziaModel> notizie = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.only(top: 10),
              child:ListView.builder(
                itemCount: notizie.length,
                itemBuilder: (context, index) {
                  return NewsCard(notizia: notizie[index]);
                },
              ),);
          }
          else {
            return Center(
                child: Text(AppLocalizations.of(context)!.translate("NoNews")));
          }
        },
      ),
    );
  }
}