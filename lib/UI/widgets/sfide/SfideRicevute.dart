import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import '../CustomSnackBar.dart';

class SfideRicevuteSection extends StatefulWidget {
  const SfideRicevuteSection({Key? key}) : super(key: key);

  @override
  State<SfideRicevuteSection> createState() => _SfideRicevuteSectionState();
}

class _SfideRicevuteSectionState extends State<SfideRicevuteSection> {
  String? _myUsername;
  bool _isLoadingUsername = true;

  @override
  void initState() {
    super.initState();
    _fetchMyUsername();
  }

  // Recupera il nome dell'utente loggato per vedere se qualcuno lo ha sfidato
  Future<void> _fetchMyUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _myUsername = data['username'] ?? data['nome'];
            _isLoadingUsername = false;
          });
        }
      } catch (e) {
        print("Errore username: $e");
        setState(() => _isLoadingUsername = false);
      }
    }
  }

  // ACCETTA SFIDA
  Future<void> _onAccetta(SfidaModel sfida) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Aggiorna la sfida: stato accettata e assegna il mio ID
      await FirebaseFirestore.instance.collection('sfide').doc(sfida.id).update({
        'stato': 'accettata',
        'opponentId': user.uid,
      });
      CustomSnackBar.show(context, "Sfida accettata! Buon divertimento.");
    } catch (e) {
      CustomSnackBar.show(context, "Errore: $e");
    }
  }

  // RIFIUTA SFIDA
  Future<void> _onRifiuta(SfidaModel sfida) async {
    try {
      // Possiamo cancellarla o impostare stato 'rifiutata'.
      // Cancellandola sparisce anche per il mittente (invito declinato).
      await FirebaseFirestore.instance.collection('sfide').doc(sfida.id).delete();
      CustomSnackBar.show(context, "Sfida rifiutata.");
    } catch (e) {
      CustomSnackBar.show(context, "Errore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUsername) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_myUsername == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('modalita', isEqualTo: 'diretta')        // Solo dirette
          .where('stato', isEqualTo: 'aperta')            // Solo aperte
          .where('opponentName', isEqualTo: _myUsername)  // INDIRIZZATE A ME
          .snapshots(),
      builder: (context, snapshot) {

        if (snapshot.hasError) return const Text("Errore caricamento.");
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;
        final sfide = docs.map((doc) => SfidaModel.fromSnapshot(doc)).toList();

        if (sfide.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                "Non hai ricevuto nuove sfide.",
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
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
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.purple.shade100,
                        child: const Icon(Icons.mark_email_unread, color: Colors.purple),
                      ),
                      title: Text(
                        "Sfida da: ${sfida.challengerName}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sfida.nomeStruttura, style: const TextStyle(fontWeight: FontWeight.w500)),
                          Text("${sfida.dataOra} - ${sfida.livello}", style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // TASTO RIFIUTA
                          OutlinedButton.icon(
                            onPressed: () => _onRifiuta(sfida),
                            icon: const Icon(Icons.close, size: 18, color: Colors.red),
                            label: const Text("Rifiuta", style: TextStyle(color: Colors.red)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // TASTO ACCETTA
                          ElevatedButton.icon(
                            onPressed: () => _onAccetta(sfida),
                            icon: const Icon(Icons.check, size: 18, color: Colors.white),
                            label: const Text("Accetta", style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}