import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/github_config.dart';
import '../models/github_release.dart';

class UpdateRepository {
  final Dio _dio;

  UpdateRepository() : _dio = Dio();

  Future<GitHubRelease?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentComparable = GitHubRelease.comparableVersionFromString(
        packageInfo.version,
      );

      final response = await _dio.get<Map<String, dynamic>>(
        GitHubConfig.releasesUrl,
        options: Options(
          headers: {'Accept': 'application/vnd.github+json'},
          responseType: ResponseType.json,
        ),
      );

      if (response.data == null) return null;

      final release = GitHubRelease.fromJson(response.data!);
      if (release == null) return null;

      if (release.isNewerThan(currentComparable)) {
        return release;
      }

      return null;
    } on Exception catch (e) {
      debugPrint('[Update] Erro ao verificar atualização: $e');
      return null;
    }
  }
}
