import 'package:flutter/material.dart';

class ScanBarcodePage extends StatelessWidget {
  const ScanBarcodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
      ),
      body: const Center(
        child: Text('Scan Barcode Page'),
      ),
    );
  }
}

