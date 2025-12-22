import 'package:flutter/material.dart';
import '../../behaviors/AppLocalizations.dart';

class Animazione extends StatefulWidget {
  const Animazione({super.key});

  @override
  State<Animazione> createState() => _AnimazioneState();
}

class _AnimazioneState extends State<Animazione> with TickerProviderStateMixin {

  late AnimationController _controller;
  late Animation<Alignment> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<Alignment>(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,

    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.bounceOut,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Aspettiamo mezzo secondo in più per far vedere la pallina ferma
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      child: Container(
        height: 300,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          children: [
            Text(
              AppLocalizations.of(context)!.translate("Benvenuto"),
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Pavimento (Linea)
                  Positioned(
                    bottom: 0,
                    left: 10,
                    right: 10,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),

                  // Animazione Pallina
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Align(
                        alignment: _animation.value,
                        child: child,
                      );
                    },
                    child: const Icon(
                      Icons.sports_baseball,
                      size: 50,
                      color: Colors.green,
                      shadows: [
                        Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(1, 1))
                      ],
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