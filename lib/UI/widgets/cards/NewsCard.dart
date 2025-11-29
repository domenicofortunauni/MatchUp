import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../model/objects/NotiziaModel.dart';

class NewsCard extends StatelessWidget {
  final Notizia notizia;

  const NewsCard({super.key, required this.notizia});


  String _getPlaceholderImage() {
    const int numeroImmagini = 10;
    int uniqueId = notizia.titolo.hashCode.abs();
    int imageNumber = (uniqueId % numeroImmagini) + 1;
    return 'assets/images/immagini_news/defaultNews$imageNumber.jpg';
    }
  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);

    //serve per aprire il browser del telefono
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        debugPrint('Non riesco ad aprire il link: $urlString');
      }
    } catch (e) {
      debugPrint('Errore nell\'apertura del link: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final String fallbackImage = _getPlaceholderImage();
    return InkWell(
      onTap: () => _launchURL(notizia.urlArticolo),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.network(
                notizia.urlImmagine.isNotEmpty ? notizia.urlImmagine : "",
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,

                //Loading: mentre carica
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
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Image.asset(
                      fallbackImage, //Immagine calcolata in precedenza
                      fit: BoxFit.cover, //Usiamo cover per riempire bene il box
                    ),
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