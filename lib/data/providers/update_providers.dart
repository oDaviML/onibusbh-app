import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ota_update/ota_update.dart';

import '../models/github_release.dart';
import '../repositories/update_repository.dart';

final updateRepositoryProvider = Provider<UpdateRepository>((ref) {
  return UpdateRepository();
});

final updateCheckProvider = FutureProvider.autoDispose<GitHubRelease?>((
  ref,
) async {
  return ref.watch(updateRepositoryProvider).checkForUpdate();
});

class UpdateDownloadNotifier extends Notifier<AsyncValue<int>> {
  @override
  AsyncValue<int> build() => const AsyncData(0);

  Stream<OtaEvent> startDownload(String url) {
    state = const AsyncLoading();
    return OtaUpdate().execute(url, destinationFilename: 'onibusbh-update.apk');
  }

  void updateProgress(int progress) {
    state = AsyncData(progress);
  }

  void setError(Object error) {
    state = AsyncError(error, StackTrace.current);
  }

  void reset() {
    state = const AsyncData(0);
  }
}

final updateDownloadProvider =
    NotifierProvider<UpdateDownloadNotifier, AsyncValue<int>>(
      UpdateDownloadNotifier.new,
    );
