import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ota_update/ota_update.dart';

import '../../../data/models/github_release.dart';
import '../../../data/providers/update_providers.dart';

class UpdateDialog extends ConsumerStatefulWidget {
  final GitHubRelease release;

  const UpdateDialog({super.key, required this.release});

  static Future<void> show(BuildContext context, GitHubRelease release) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => UpdateDialog(release: release),
    );
  }

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  bool _downloading = false;
  int _progress = 0;
  String? _error;

  Future<void> _startDownload() async {
    setState(() {
      _downloading = true;
      _progress = 0;
      _error = null;
    });

    final notifier = ref.read(updateDownloadProvider.notifier);
    final stream = notifier.startDownload(widget.release.apkDownloadUrl);

    await for (final event in stream) {
      switch (event.status) {
        case OtaStatus.DOWNLOADING:
          final value = int.tryParse(event.value ?? '0') ?? 0;
          setState(() => _progress = value);
          notifier.updateProgress(value);
        case OtaStatus.INSTALLING:
          if (mounted) Navigator.of(context).pop();
        case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
          setState(() {
            _error = 'Permissão de instalação negada.';
            _downloading = false;
          });
          notifier.reset();
        default:
          setState(() {
            _error = 'Erro durante o download.';
            _downloading = false;
          });
          notifier.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      icon: Icon(Icons.system_update, size: 48, color: colorScheme.primary),
      title: const Text('Atualização disponível'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Versão ${widget.release.version}',
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          if (widget.release.body.isNotEmpty) ...[
            SizedBox(
              height: 120,
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Text(
                  widget.release.body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          if (_downloading) ...[
            LinearProgressIndicator(
              value: _progress > 0 ? _progress / 100 : null,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              _progress > 0
                  ? 'Baixando... $_progress%'
                  : 'Iniciando download...',
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (!_downloading && _error != null)
          TextButton(
            onPressed: _startDownload,
            child: const Text('Tentar novamente'),
          ),
        if (!_downloading && _error == null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Depois'),
          ),
        if (!_downloading && _error == null)
          FilledButton.icon(
            onPressed: _startDownload,
            icon: const Icon(Icons.download),
            label: const Text('Atualizar'),
          ),
      ],
    );
  }
}
