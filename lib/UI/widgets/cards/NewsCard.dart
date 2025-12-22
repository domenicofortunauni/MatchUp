import 'package:flutter/material.dart';
import '../../../model/objects/NotiziaModel.dart';
import '../../../services/gnews_service.dart';

class NewsCard extends StatelessWidget {
  final NotiziaModel notizia;
  const NewsCard({super.key, required this.notizia});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => launchURL(notizia.urlArticolo),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                notizia.urlImmagine,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                //mentre carica
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null)
                    return child;
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
                      getImmagineDefaultRandom(notizia), //Immagine di fallback
                      fit: BoxFit.cover,
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