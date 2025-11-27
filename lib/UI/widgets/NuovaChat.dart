import 'package:flutter/material.dart';
import '../../services/sfida_consigliati_service.dart';
import '../pages/ChatPage.dart';

class NuovaChatPopup extends StatelessWidget {
  const NuovaChatPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final UserService userService = UserService();

    return Container(
      padding: const EdgeInsets.all(16),
      height: MediaQuery.of(context).size.height * 0.7,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            "Giocatori Consigliati",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 5),
          const Text("Sfidali o inizia una conversazione"),
          const Divider(height: 20),

          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              // funzione "intelllliggente"
              future: userService.getSuggestedPlayers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Nessun giocatore trovato al momento."));
                }

                final users = snapshot.data!;

                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (ctx, i) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final String name = user['displayName'] ?? user['username'] ?? "Giocatore";
                    final String uid = user['uid'];
                    final String city = user['citta'] ?? "Non specificata";
                    final String tag = user['ui_tag'] ?? ""; // Vicini

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),

                      leading: CircleAvatar(
                        backgroundColor: Colors.blueGrey.shade50,
                        radius: 26,
                        child: Text(name[0].toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                      ),

                      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 2),
                          Text(city, style: const TextStyle(fontSize: 12)),
                        ],
                      ),

                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (tag == "Vicino a te")
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.green, width: 0.5)
                              ),
                              child: const Text("Vicino", style: TextStyle(fontSize: 10, color: Colors.green, fontWeight: FontWeight.bold)),
                            ),
                          const SizedBox(width: 10),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                        ],
                      ),

                      onTap: () {
                        Navigator.pop(context); // Chiude popup
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                                receiverId: uid,
                                receiverName: name
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}