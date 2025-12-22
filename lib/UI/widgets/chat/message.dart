import 'package:flutter/material.dart';

class Message extends StatelessWidget {
  final String message;
  final bool isMe;
  final DateTime time;

  const Message( {
    Key? key,
    required this.message,
    required this.isMe,
    required this.time,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? Theme.of(context).primaryColor : Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message,
              style: TextStyle(
                color: isMe ? Colors.white : Theme.of(context).colorScheme.inverseSurface,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${time.hour}:${time.minute.toString().padLeft(2, '0')}",
              style: TextStyle(
                color: isMe ? Colors.white70 : Theme.of(context).colorScheme.inverseSurface,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}