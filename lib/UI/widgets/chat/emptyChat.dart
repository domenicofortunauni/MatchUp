import 'package:flutter/material.dart';

class EmptyChat extends StatelessWidget {
  final String message;
  const EmptyChat({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey),
          const SizedBox(height: 20),
          Text(message, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
