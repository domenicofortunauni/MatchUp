import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:matchup/UI/behaviors/AppLocalizations.dart';

class Animazione extends StatefulWidget {
  const Animazione({super.key});

  @override
  State<Animazione> createState() => _AnimazioneState();
}

class _AnimazioneState extends State<Animazione> with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 300), () {
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
      clipBehavior: Clip.hardEdge,
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double maxWidth = constraints.maxWidth;
                  final double maxHeight = constraints.maxHeight;
                  const double ballSize = 50.0;
                  final double floorY = maxHeight - ballSize - 2;

                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      //Pavimento
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

                      AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          double t = _controller.value;

                          //Fisica orizzontale (X)
                          double tX = Curves.easeOutQuad.transform(t);
                          double startX = -150.0;
                          double endX = maxWidth + 50.0;
                          double x = startX + (tX * (endX - startX));

                          //Fisica verticale (Y)
                          double y;

                          //Caduta iniziale
                          if (t < 0.22) {
                            double subT = const Interval(0.0, 0.22, curve: Curves.easeInQuad).transform(t);
                            double startH = -120.0; // Parte un po' più basso
                            y = startH + (subT * (floorY - startH));
                          }
                          //Primo rimbalzo
                          else if (t < 0.45) {
                            double jumpHeight = 90.0;
                            if (t < 0.335) { //Salita
                              double subT = const Interval(0.22, 0.335, curve: Curves.easeOutQuad).transform(t);
                              y = floorY - (subT * jumpHeight);
                            } else { //Discesa
                              double subT = const Interval(0.335, 0.45, curve: Curves.easeInQuad).transform(t);
                              y = (floorY - jumpHeight) + (subT * jumpHeight);
                            }
                          }
                          //Secondo rimbalzo
                          else if (t < 0.63) {
                            double jumpHeight = 45.0;
                            if (t < 0.54) {
                              double subT = const Interval(0.45, 0.54, curve: Curves.easeOutQuad).transform(t);
                              y = floorY - (subT * jumpHeight);
                            } else {
                              double subT = const Interval(0.54, 0.63, curve: Curves.easeInQuad).transform(t);
                              y = (floorY - jumpHeight) + (subT * jumpHeight);
                            }
                          }
                          //Terzo rimbalzo
                          else if (t < 0.77) {
                            double jumpHeight = 25.0;
                            if (t < 0.70) {
                              double subT = const Interval(0.63, 0.70, curve: Curves.easeOutQuad).transform(t);
                              y = floorY - (subT * jumpHeight);
                            } else {
                              double subT = const Interval(0.70, 0.77, curve: Curves.easeInQuad).transform(t);
                              y = (floorY - jumpHeight) + (subT * jumpHeight);
                            }
                          }
                          //Quarto rimbalzo
                          else if (t < 0.88) {
                            double jumpHeight = 10.0;
                            if (t < 0.825) {
                              double subT = const Interval(0.77, 0.825, curve: Curves.easeOutQuad).transform(t);
                              y = floorY - (subT * jumpHeight);
                            } else {
                              double subT = const Interval(0.825, 0.88, curve: Curves.easeInQuad).transform(t);
                              y = (floorY - jumpHeight) + (subT * jumpHeight);
                            }
                          }
                          //Quinto rimbalzo molto piccolo
                          else if (t < 0.94) {
                            double jumpHeight = 2.0;
                            if (t < 0.91) {
                              double subT = const Interval(0.88, 0.91, curve: Curves.easeOut).transform(t);
                              y = floorY - (subT * jumpHeight);
                            } else {
                              double subT = const Interval(0.91, 0.94, curve: Curves.easeIn).transform(t);
                              y = (floorY - jumpHeight) + (subT * jumpHeight);
                            }
                          }
                          //Rotolamento finale
                          else {
                            y = floorY;
                          }

                          //Rotazione
                          double rotation = tX * (8 * math.pi);

                          return Positioned(
                            left: x,
                            top: y,
                            child: Transform.rotate(
                              angle: rotation,
                              child: child,
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.sports_baseball,
                          size: ballSize,
                          color: Colors.green,
                          shadows: [
                            Shadow(color: Colors.black12, blurRadius: 2, offset: Offset(1, 1))
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}