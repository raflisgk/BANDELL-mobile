import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/history_lamp_model.dart';
import '../models/installation_model.dart';
import 'api_service.dart';
import 'lamp_type_service.dart';

class InstallationService {
  /// Simpan data pemasangan lampu baru ke Laravel API
  Future<InstallationModel> createInstallation(
    InstallationModel installation,
  ) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/installations',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.headers.addAll(
      ApiService.multipartHeaders,
    );

    // =========================
    // DATA INSTALLATION
    // =========================

    request.fields['project_id'] =
        installation.idProject?.toString() ?? '';

    request.fields['user_id'] =
        installation.idUser?.toString() ?? '';

    request.fields['lamp_type_id'] =
        installation.lampTypeId?.toString() ?? '';

    request.fields['district_id'] =
        installation.idArea.toString();

    request.fields['id_lcu'] =
    installation.lampCode;

    // Laravel menerima: realtime / manual
    request.fields['input_method'] =
        (installation.inputMethod ?? '').toLowerCase();

    request.fields['latitude'] =
        installation.latitude ?? '';

    request.fields['longitude'] =
        installation.longitude ?? '';

    if (installation.panelCode != null &&
        installation.panelCode!.trim().isNotEmpty) {
      request.fields['code_panel'] =
          installation.panelCode!.trim();
    }

    if (installation.notes != null &&
        installation.notes!.trim().isNotEmpty) {
      request.fields['address'] =
          installation.notes!.trim();
    }

    // installed_at menggunakan tanggal saja
    if (installation.createdAt != null) {
      request.fields['installed_at'] =
          installation.createdAt!
              .toIso8601String()
              .split('T')
              .first;
    }

    // =========================
    // FOTO
    // =========================

    for (final photoPath in installation.photos) {
      if (photoPath.trim().isEmpty) {
        continue;
      }

      final file = File(photoPath);
      if (file.existsSync()) {
        final photo = await http.MultipartFile.fromPath(
          'photos[]',
          photoPath,
        );
        request.files.add(photo);
      }
    }

    // =========================
    // DEBUG
    // =========================

    debugPrint('========== CREATE INSTALLATION ==========');
    debugPrint('project_id   : ${request.fields['project_id']}');
    debugPrint('user_id      : ${request.fields['user_id']}');
    debugPrint('lamp_type_id : ${request.fields['lamp_type_id']}');
    debugPrint('district_id  : ${request.fields['district_id']}');
    debugPrint('id_lcu       : ${request.fields['id_lcu']}');
    debugPrint('input_method : ${request.fields['input_method']}');
    debugPrint('latitude     : ${request.fields['latitude']}');
    debugPrint('longitude    : ${request.fields['longitude']}');
    debugPrint('code_panel   : ${request.fields['code_panel']}');
    debugPrint('jumlah foto  : ${request.files.length}');
    debugPrint('=========================================');

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    debugPrint('INSTALLATION STATUS: ${response.statusCode}');
    debugPrint('INSTALLATION RESPONSE: ${response.body}');

    // =========================
    // RESPONSE
    // =========================

    Map<String, dynamic> responseData;

    try {
      responseData =
          jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(
        'Response server tidak valid.',
      );
    }

    if (response.statusCode == 201 &&
        responseData['success'] == true) {
      final data = responseData['data'];

      if (data is Map<String, dynamic>) {
        final parsed = InstallationModel.fromJson(data);
        debugPrint('PARSED INPUT METHOD: ${parsed.inputMethod}');
        return parsed;
      }

      return installation;
    }

    throw Exception(
      _extractErrorMessage(responseData, 'Gagal menyimpan data pemasangan.'),
    );
  }

  /// Mengambil detail record lampu berdasarkan ID dari Laravel API
  Future<InstallationModel?> getInstallationDetail(int idInstallation) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/installations/$idInstallation'),
      headers: ApiService.defaultHeaders,
    );

    debugPrint('DETAIL STATUS: ${response.statusCode}');
    debugPrint('INSTALLATION RESPONSE: ${response.body}');

    if (response.statusCode == 404) {
      return null;
    }

    Map<String, dynamic> responseData = {};
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Response server tidak valid.');
    }

    if (response.statusCode == 200 && responseData['success'] == true) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        final parsed = InstallationModel.fromJson(data);
        debugPrint('PARSED INPUT METHOD: ${parsed.inputMethod}');
        return parsed;
      }
    }

    throw Exception(
      _extractErrorMessage(responseData, 'Gagal mengambil detail data pemasangan.'),
    );
  }

  /// Mengubah data lampu berdasarkan ID ke Laravel API
  /// Menggunakan POST + _method=PUT untuk kompatibilitas multipart Laravel
  Future<InstallationModel> updateInstallation(
    int idInstallation,
    InstallationModel installation,
  ) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/installations/$idInstallation',
    );

    final request = http.MultipartRequest(
      'POST',
      uri,
    );

    request.headers.addAll(
      ApiService.multipartHeaders,
    );

    // Method spoofing untuk Laravel
    request.fields['_method'] = 'PUT';

    if (installation.idProject != null && installation.idProject! > 0) {
      request.fields['project_id'] = installation.idProject.toString();
    }

    if (installation.idUser != null && installation.idUser! > 0) {
      request.fields['user_id'] = installation.idUser.toString();
    }

    // Lamp Type ID
    if (installation.lampTypeId != null && installation.lampTypeId! > 0) {
      request.fields['lamp_type_id'] = installation.lampTypeId.toString();
    } else if (installation.lampType.isNotEmpty) {
      try {
        final types = await LampTypeService().getLampTypes();
        final match = types.firstWhere(
          (t) => t.name.toLowerCase() == installation.lampType.toLowerCase(),
        );
        request.fields['lamp_type_id'] = match.id.toString();
      } catch (_) {
        // Fallback jika tidak ditemukan
      }
    }

    // Hanya kirim district_id jika idProject juga valid
    if (installation.idArea > 0 &&
        installation.idProject != null &&
        installation.idProject! > 0) {
      request.fields['district_id'] = installation.idArea.toString();
    }

    if (installation.lampCode.isNotEmpty) {
      request.fields['id_lcu'] = installation.lampCode;
    }

    if (installation.inputMethod != null &&
        installation.inputMethod!.trim().isNotEmpty) {
      request.fields['input_method'] =
          installation.inputMethod!.trim().toLowerCase();
    }

    if (installation.latitude != null &&
        installation.latitude!.trim().isNotEmpty) {
      request.fields['latitude'] = installation.latitude!.trim();
    }

    if (installation.longitude != null &&
        installation.longitude!.trim().isNotEmpty) {
      request.fields['longitude'] = installation.longitude!.trim();
    }

    if (installation.notes != null && installation.notes!.trim().isNotEmpty) {
      request.fields['address'] = installation.notes!.trim();
    }

    if (installation.panelCode != null &&
        installation.panelCode!.trim().isNotEmpty) {
      request.fields['code_panel'] = installation.panelCode!.trim();
    }

    if (installation.createdAt != null) {
      request.fields['installed_at'] =
          installation.createdAt!.toIso8601String().split('T').first;
    } else if (installation.updatedAt != null) {
      request.fields['installed_at'] =
          installation.updatedAt!.toIso8601String().split('T').first;
    }

    // Foto tambahan
    for (final photoPath in installation.photos) {
      if (photoPath.trim().isEmpty) {
        continue;
      }

      final file = File(photoPath);
      if (file.existsSync()) {
        final photo = await http.MultipartFile.fromPath(
          'photos[]',
          photoPath,
        );
        request.files.add(photo);
      }
    }

    debugPrint('========== UPDATE INSTALLATION ==========');
    debugPrint('id           : $idInstallation');
    debugPrint('fields       : ${request.fields}');
    debugPrint('files        : ${request.files.length}');
    debugPrint('=========================================');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('UPDATE STATUS: ${response.statusCode}');
    debugPrint('UPDATE BODY: ${response.body}');

    Map<String, dynamic> responseData = {};
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Response server tidak valid.');
    }

    if ((response.statusCode == 200 || response.statusCode == 201) &&
        responseData['success'] == true) {
      final data = responseData['data'];
      if (data is Map<String, dynamic>) {
        return InstallationModel.fromJson(data);
      }
      return installation;
    }

    throw Exception(
      _extractErrorMessage(responseData, 'Gagal memperbarui data pemasangan.'),
    );
  }

  /// Menghapus data lampu berdasarkan ID dari Laravel API
  Future<bool> deleteInstallation(int idInstallation) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/installations/$idInstallation'),
      headers: ApiService.defaultHeaders,
    );

    debugPrint('DELETE STATUS: ${response.statusCode}');
    debugPrint('DELETE BODY: ${response.body}');

    Map<String, dynamic> responseData = {};
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Response server tidak valid.');
    }

    if (response.statusCode == 200 && responseData['success'] == true) {
      return true;
    }

    throw Exception(
      _extractErrorMessage(responseData, 'Gagal menghapus data pemasangan.'),
    );
  }

  /// Mengambil riwayat pendataan lampu berdasarkan user dan project dari Laravel API
  Future<List<HistoryLampModel>> getHistory({
    required int userId,
    required int projectId,
    String? filter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParameters = <String, String>{
      'user_id': userId.toString(),
      'project_id': projectId.toString(),
    };

    if (filter != null && filter.trim().isNotEmpty) {
      final districtId = int.tryParse(filter.trim());
      if (districtId != null) {
        queryParameters['district_id'] = districtId.toString();
      }
    }

    if (startDate != null) {
      queryParameters['start_date'] =
          startDate.toIso8601String().split('T').first;
    }

    if (endDate != null) {
      queryParameters['end_date'] =
          endDate.toIso8601String().split('T').first;
    }

    final uri = Uri.parse(
      '${ApiService.baseUrl}/installations',
    ).replace(
      queryParameters: queryParameters,
    );

    debugPrint('HISTORY URL: $uri');

    final response = await http.get(
      uri,
      headers: ApiService.defaultHeaders,
    );

    debugPrint('HISTORY STATUS: ${response.statusCode}');
    debugPrint('INSTALLATION RESPONSE: ${response.body}');

    Map<String, dynamic> responseData = {};
    try {
      responseData = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception('Response server tidak valid.');
    }

    if (response.statusCode == 200 && responseData['success'] == true) {
      final List data = responseData['data'] ?? [];
      debugPrint('HISTORY RESPONSE COUNT: ${data.length}');
      return data
          .map(
            (item) {
              final map = item as Map<String, dynamic>;
              debugPrint('API input_method: ${map['input_method']}');
              return HistoryLampModel.fromJson(map);
            },
          )
          .toList();
    }

    throw Exception(
      _extractErrorMessage(responseData, 'Gagal mengambil riwayat pendataan.'),
    );
  }

  /// Ekstraksi pesan error dari response Laravel (422, 403, dsb)
  static String _extractErrorMessage(
    Map<String, dynamic> responseData,
    String defaultMessage,
  ) {
    if (responseData['message'] != null &&
        responseData['message'].toString().trim().isNotEmpty) {
      return responseData['message'].toString();
    }

    if (responseData['errors'] is Map) {
      final errors = responseData['errors'] as Map;
      if (errors.isNotEmpty) {
        final firstVal = errors.values.first;
        if (firstVal is List && firstVal.isNotEmpty) {
          return firstVal.first.toString();
        }
        return firstVal.toString();
      }
    }

    return defaultMessage;
  }
}