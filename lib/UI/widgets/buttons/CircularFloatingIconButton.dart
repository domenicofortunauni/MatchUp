import 'package:flutter/material.dart';

class CircularFloatingIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const CircularFloatingIconButton({required this.icon, required this.onPressed}) : super();
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 90.0),
        child: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: onPressed,
        shape: CircleBorder(),
        child: Icon(
          icon, color: Colors.white,
        ),
      )
    );
  }
}