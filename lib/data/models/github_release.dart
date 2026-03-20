class GitHubRelease {
  final String tagName;
  final String name;
  final String body;
  final String apkDownloadUrl;
  final int comparableVersion;

  const GitHubRelease({
    required this.tagName,
    required this.name,
    required this.body,
    required this.apkDownloadUrl,
    required this.comparableVersion,
  });

  String get version => tagName.replaceFirst('v', '');

  bool isNewerThan(int currentComparableVersion) {
    return comparableVersion > currentComparableVersion;
  }

  static GitHubRelease? fromJson(Map<String, dynamic> json) {
    final assets = json['assets'] as List<dynamic>?;
    if (assets == null || assets.isEmpty) return null;

    final apkAsset = assets.cast<Map<String, dynamic>>().firstWhere(
      (asset) => (asset['name'] as String?)?.endsWith('.apk') == true,
      orElse: () => {},
    );
    if (apkAsset.isEmpty) return null;

    final downloadUrl = apkAsset['browser_download_url'] as String?;
    if (downloadUrl == null) return null;

    final tagName = json['tag_name'] as String? ?? '';
    final versionString = tagName.replaceFirst('v', '');
    final parts = versionString.split('.');
    final major = int.tryParse(parts.elementAtOrNull(0) ?? '0') ?? 0;
    final minor = int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0;
    final patch = int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0;
    final comparable = major * 1000000 + minor * 10000 + patch * 100;

    return GitHubRelease(
      tagName: tagName,
      name: json['name'] as String? ?? tagName,
      body: json['body'] as String? ?? '',
      apkDownloadUrl: downloadUrl,
      comparableVersion: comparable,
    );
  }

  static int comparableVersionFromString(String version) {
    final parts = version.split('.');
    final major = int.tryParse(parts.elementAtOrNull(0) ?? '0') ?? 0;
    final minor = int.tryParse(parts.elementAtOrNull(1) ?? '0') ?? 0;
    final patch = int.tryParse(parts.elementAtOrNull(2) ?? '0') ?? 0;
    return major * 1000000 + minor * 10000 + patch * 100;
  }
}
