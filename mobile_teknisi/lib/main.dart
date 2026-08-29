import 'package:flutter/material.dart';

import 'screens/lamp_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BANDELL',
      home: const LampPage(
        idOperationalArea: 1,
      ),
    );
  }
}