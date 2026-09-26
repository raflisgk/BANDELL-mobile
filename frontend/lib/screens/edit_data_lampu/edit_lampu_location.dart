import 'package:flutter/material.dart';

import '../../widgets/lokasi_koordinat.dart';

class EditLampuLocation extends StatelessWidget {
  final TextEditingController longitudeController;
  final TextEditingController latitudeController;
  final FocusNode longitudeFocusNode;
  final FocusNode latitudeFocusNode;
  final String? errorMessage;

  const EditLampuLocation({
    super.key,
    required this.longitudeController,
    required this.latitudeController,
    required this.longitudeFocusNode,
    required this.latitudeFocusNode,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return LokasiKoordinat(
      latitudeController: latitudeController,
      longitudeController: longitudeController,
      latitudeFocusNode: latitudeFocusNode,
      longitudeFocusNode: longitudeFocusNode,
      errorMessage: errorMessage,
      latitudeHint: '-6.2088',
      longitudeHint: '106.8456',
    );
  }
}
