import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/history_lamp_model.dart';
import '../models/installation_model.dart';
import 'api_service.dart';

class InstallationService {
  /// Menyimpan data pendataan lampu baru ke Laravel
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

    // Data utama
    request.fields['project_id'] =
        installation.idProject?.toString() ?? '';

    request.fields['user_id'] =
        installation.idUser?.toString() ?? '';

    request.fields['lamp_type_id'] =
        installation.lampTypeId?.toString() ?? '';

    request.fields['district_id'] =
        installation.idArea.toString();

    request.fields['id_barcode'] =
        installation.lampCode;

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

    if (installation.createdAt != null) {
      request.fields['installed_at'] =
          installation.createdAt!
              .toIso8601String()
              .split('T')
              .first;
    }

    // Foto dokumentasi
    for (final photoPath in installation.photos) {
      try {
        final file = await http.MultipartFile.fromPath(
          'photos[]',
          photoPath,
        );

        request.files.add(file);
      } catch (e) {
        throw Exception(
          'Gagal membaca foto dokumentasi: $e',
        );
      }
    }

    print('INSTALLATION REQUEST:');
    print('project_id: ${request.fields['project_id']}');
    print('user_id: ${request.fields['user_id']}');
    print('lamp_type_id: ${request.fields['lamp_type_id']}');
    print('district_id: ${request.fields['district_id']}');
    print('id_barcode: ${request.fields['id_barcode']}');
    print('input_method: ${request.fields['input_method']}');
    print('latitude: ${request.fields['latitude']}');
    print('longitude: ${request.fields['longitude']}');
    print('code_panel: ${request.fields['code_panel']}');
    print('jumlah foto: ${request.files.length}');

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    print(
      'INSTALLATION STATUS: ${response.statusCode}',
    );

    print(
      'INSTALLATION BODY: ${response.body}',
    );

    Map<String, dynamic> responseData = {};

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
        return InstallationModel.fromJson(data);
      }

      return installation;
    }

    throw Exception(
      responseData['message']?.toString() ??
          'Gagal menyimpan data pemasangan.',
    );
  }

  /// Mengambil detail record lampu
  Future<InstallationModel?> getInstallationDetail(
    int idInstallation,
  ) async {
    final response = await http.get(
      Uri.parse(
        '${ApiService.baseUrl}/installations/$idInstallation',
      ),
      headers: ApiService.defaultHeaders,
    );

    print(
      'INSTALLATION DETAIL STATUS: ${response.statusCode}',
    );

    print(
      'INSTALLATION DETAIL BODY: ${response.body}',
    );

    if (response.statusCode != 200) {
      return null;
    }

    final responseData =
        jsonDecode(response.body);

    final data = responseData['data'];

    if (data is! Map<String, dynamic>) {
      return null;
    }

    return InstallationModel.fromJson(data);
  }

  /// Mengubah data lampu
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

    // Laravel method spoofing
    request.fields['_method'] = 'PUT';

    request.fields['project_id'] =
        installation.idProject?.toString() ?? '';

    request.fields['user_id'] =
        installation.idUser?.toString() ?? '';

    request.fields['lamp_type_id'] =
        installation.lampTypeId?.toString() ?? '';

    request.fields['district_id'] =
        installation.idArea.toString();

    request.fields['id_barcode'] =
        installation.lampCode;

    request.fields['input_method'] =
        (installation.inputMethod ?? '').toLowerCase();

    request.fields['latitude'] =
        installation.latitude ?? '';

    request.fields['longitude'] =
        installation.longitude ?? '';

    if (installation.panelCode != null) {
      request.fields['code_panel'] =
          installation.panelCode!;
    }

    if (installation.installedAt != null) {
      request.fields['installed_at'] =
          installation.installedAt!
              .toIso8601String()
              .split('T')
              .first;
    }

    for (final photoPath in installation.photos) {
      final file = await http.MultipartFile.fromPath(
        'photos[]',
        photoPath,
      );

      request.files.add(file);
    }

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    print(
      'UPDATE INSTALLATION STATUS: ${response.statusCode}',
    );

    print(
      'UPDATE INSTALLATION BODY: ${response.body}',
    );

    final responseData =
        jsonDecode(response.body);

    if (response.statusCode == 200 &&
        responseData['success'] == true) {
      return InstallationModel.fromJson(
        responseData['data'],
      );
    }

    throw Exception(
      responseData['message']?.toString() ??
          'Gagal memperbarui data pemasangan.',
    );
  }

  /// Menghapus data lampu
  Future<bool> deleteInstallation(
    int idInstallation,
  ) async {
    final response = await http.delete(
      Uri.parse(
        '${ApiService.baseUrl}/installations/$idInstallation',
      ),
      headers: ApiService.defaultHeaders,
    );

    print(
      'DELETE INSTALLATION STATUS: ${response.statusCode}',
    );

    print(
      'DELETE INSTALLATION BODY: ${response.body}',
    );

    if (response.statusCode == 200) {
      final responseData =
          jsonDecode(response.body);

      return responseData['success'] == true;
    }

    return false;
  }

  /// Mengambil riwayat pendataan berdasarkan user + project
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

    if (filter != null &&
        filter.trim().isNotEmpty) {
      queryParameters['district_id'] =
          filter.trim();
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

    final response = await http.get(
      uri,
      headers: ApiService.defaultHeaders,
    );

    print(
      'HISTORY STATUS: ${response.statusCode}',
    );

    print(
      'HISTORY BODY: ${response.body}',
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil riwayat pendataan.',
      );
    }

    final responseData =
        jsonDecode(response.body);

    final List data =
        responseData['data'] ?? [];

    return data
        .map(
          (item) => HistoryLampModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}