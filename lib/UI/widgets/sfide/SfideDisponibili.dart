import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';

class SfideDisponibiliList extends StatelessWidget {
  const SfideDisponibiliList({Key? key}) : super(key: key);

  Future<void> _accettaSfida(BuildContext context, SfidaModel sfida) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      String myName = "Avversario";
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        myName = userDoc.data()?['username'] ?? "Avversario";
      }

      // Aggiorniamo la sfida inserendo opponentId e opponentName
      await FirebaseFirestore.instance.collection('sfide').doc(sfida.id).update({
        'opponentId': user.uid,
        'opponentName': myName, // <--- Salviamo il nome di chi accetta
        'stato': 'accettata'
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Hai accettato la sfida di ${sfida.challengerName}!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Errore: $e")),
      );
    }
  }

  Color _getLevelColor(String livello) {
    String l = livello.toLowerCase();
    if (l.contains("principiante")) return Colors.green;
    if (l.contains("intermedio")) return Colors.orange;
    if (l.contains("avanzato") || l.contains("esperto")) return Colors.red;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('stato', isEqualTo: 'aperta')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Errore caricamento sfide");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        final sfide = docs
            .map((doc) => SfidaModel.fromSnapshot(doc))
            .where((s) => s.challengerId != currentUserId)
            .toList();

        if (sfide.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text("Nessuna sfida disponibile al momento.", style: TextStyle(color: Colors.grey)),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sfide.length,
          itemBuilder: (context, index) {
            final sfida = sfide[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.flash_on, color: Colors.amber),
                ),
                title: Text(
                    "vs ${sfida.challengerName}",
                    style: const TextStyle(fontWeight: FontWeight.bold)
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sfida.nomeStruttura, style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(sfida.dataOra, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                              color: _getLevelColor(sfida.livello).withValues(alpha: 0.1),
                              border: Border.all(color: _getLevelColor(sfida.livello).withValues(alpha: 0.5)),
                              borderRadius: BorderRadius.circular(4)
                          ),
                          child: Text(
                            sfida.livello,
                            style: TextStyle(fontSize: 10, color: _getLevelColor(sfida.livello), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  ),
                  onPressed: () => _accettaSfida(context, sfida),
                  child: const Text('Accetta', style: TextStyle(fontSize: 13, color: Colors.white)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}