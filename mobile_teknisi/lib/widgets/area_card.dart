import 'package:flutter/material.dart';

class AreaCard extends StatelessWidget {
  const AreaCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Area Card'),
      ),
    );
  }
}

