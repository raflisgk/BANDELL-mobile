import 'package:flutter/material.dart';

class LampCard extends StatelessWidget {
  const LampCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Lamp Card'),
      ),
    );
  }
}

