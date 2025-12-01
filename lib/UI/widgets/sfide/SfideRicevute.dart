import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matchup/model/objects/SfidaModel.dart';
import 'package:matchup/UI/widgets/cards/SfidaCard.dart'; // Importa la card
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

  Future<void> _fetchMyUsername() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          setState(() {
            _myUsername = doc['username'] ?? doc['nome'];
            _isLoadingUsername = false;
          });
        }
      } catch (e) {
        setState(() => _isLoadingUsername = false);
      }
    }
  }

  Future<void> _onAccetta(SfidaModel sfida) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await FirebaseFirestore.instance.collection('sfide').doc(sfida.id).update({
        'stato': 'accettata',
        'opponentId': user.uid,
      });
      if (mounted) CustomSnackBar.show(context, "Sfida accettata!");
    } catch (e) {
      if (mounted) CustomSnackBar.show(context, "Errore: $e");
    }
  }

  Future<void> _onRifiuta(SfidaModel sfida) async {
    try {
      await FirebaseFirestore.instance.collection('sfide').doc(sfida.id).delete();
      if (mounted) CustomSnackBar.show(context, "Sfida rifiutata.");
    } catch (e) {
      if (mounted) CustomSnackBar.show(context, "Errore: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingUsername) return const Center(child: CircularProgressIndicator());
    if (_myUsername == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sfide')
          .where('modalita', isEqualTo: 'diretta')
          .where('stato', isEqualTo: 'aperta')
          .where('opponentName', isEqualTo: _myUsername)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text("Errore caricamento.");
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        final sfide = docs.map((doc) => SfidaModel.fromSnapshot(doc)).toList();

        if (sfide.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mark_email_read_rounded, size: 48, color: Colors.grey.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text("Nessuna sfida ricevuta", style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          itemCount: sfide.length,
          itemBuilder: (context, index) {
            final sfida = sfide[index];

            // RICICLO DELLA SFIDA CARD
            return SfidaCard(
              sfida: sfida,
              customTitle: "Sfida da: ${sfida.challengerName}",

              extraWidget: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _onRifiuta(sfida),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Rifiuta"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _onAccetta(sfida),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text("Accetta", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ), customIcon: Icons.mark_email_unread,
            );
          },
        );
      },
    );
  }
}