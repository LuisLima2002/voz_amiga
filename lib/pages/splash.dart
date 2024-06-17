import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.purple[600],
      ),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  "images/AlaskaCode.png",
                  fit: BoxFit.cover,
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text(
              "Voz Amiga",
              style: TextStyle(
                fontSize: 40,
                color: Colors.white,
                decoration: TextDecoration.none,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              "ALASKA",
              style: TextStyle(
                fontSize: 20,
                color: Colors.blueGrey[100],
                decoration: TextDecoration.none,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
