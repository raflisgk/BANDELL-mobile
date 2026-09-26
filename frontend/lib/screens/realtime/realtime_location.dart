import 'package:flutter/material.dart';

import '../../widgets/lokasi_koordinat.dart';

class RealtimeLocationSection extends StatelessWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final FocusNode? latitudeFocusNode;
  final FocusNode? longitudeFocusNode;
  final bool isLoadingLocation;
  final VoidCallback onGetLocation;
  final String? errorMessage;

  const RealtimeLocationSection({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    this.latitudeFocusNode,
    this.longitudeFocusNode,
    required this.isLoadingLocation,
    required this.onGetLocation,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return LokasiKoordinat(
      latitudeController: latitudeController,
      longitudeController: longitudeController,
      latitudeFocusNode: latitudeFocusNode,
      longitudeFocusNode: longitudeFocusNode,
      isGpsMode: true,
      isLoadingGps: isLoadingLocation,
      onGetGpsLocation: onGetLocation,
      errorMessage: errorMessage,
      readOnly: true,
    );
  }
}
