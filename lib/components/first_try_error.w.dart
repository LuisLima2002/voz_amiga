import 'package:flutter/material.dart';

class FirstTryError extends StatelessWidget {
  const FirstTryError({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.dangerous,
          color: Color(0xFF770000),
          size: 35,
        ),
        Text(
          "Algo deu errado!",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF770000),
          ),
        ),
        Text(
          "Tenta mais tarde",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF770000),
          ),
        ),
      ],
    );
  }
}
