import 'package:flutter/material.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';
import 'package:matchup/UI/behaviors/gnews_service.dart'; // Importa il servizio creato

class News extends StatelessWidget {
  const News({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.translate("News")), // Assumi di avere una chiave 'newsPageTitle'
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Notizia>>(
        future: fetchNews(), // Chiama la funzione API
        builder: (context, snapshot) {

          // Stato 1: Caricamento
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Stato 2: Errore
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

          // Stato 3: Dati Pronti
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

          // Stato 4: Nessun Dato
          else {
            return Center(child: Text(AppLocalizations.of(context)!.translate("News")));
          }
        },
      ),
    );
  }
}

// --- Widget per la Singola Notizia (NewsCard) ---

class NewsCard extends StatelessWidget {
  final Notizia notizia;

  const NewsCard({super.key, required this.notizia});

  void _launchURL(String url) async {
    // In un'app reale, dovrai usare un package come url_launcher
    // per aprire il link nel browser.
    // L'implementazione completa non è qui per mantenere il codice focalizzato.
    print('Opening URL: $url');
    // Esempio per url_launcher: await launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _launchURL(notizia.urlArticolo), // Apre l'articolo
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Immagine della notizia
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                notizia.urlImmagine,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    height: 180,
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 180,
                    color: Colors.grey[200],
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titolo
                  Text(
                    notizia.titolo,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Descrizione
                  Text(
                    notizia.descrizione,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  // Fonte
                  Text(
                    'Fonte: ${notizia.fonte}',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}