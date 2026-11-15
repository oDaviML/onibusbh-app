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

    final normalizedBody = GitHubRelease.normalizeBody(widget.release.body);

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
          if (normalizedBody.isNotEmpty) ...[
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: _buildReleaseNotes(normalizedBody, theme),
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

  Widget _buildReleaseNotes(String body, ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.8),
      height: 1.35,
    );
    final headingStyle = theme.textTheme.labelLarge?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w700,
    );

    final children = <Widget>[];
    for (final rawLine in body.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      if (line.startsWith('#') || _isStandaloneSectionTitle(line)) {
        final title = line.replaceFirst(RegExp(r'^#{1,6}\s*'), '').trim();
        if (title.isEmpty) continue;
        children.add(
          Padding(
            padding: EdgeInsets.only(top: children.isEmpty ? 0 : 8, bottom: 4),
            child: Text(title, style: headingStyle),
          ),
        );
      } else if (line.startsWith('- ') || line.startsWith('* ')) {
        final bulletText = line.substring(2).trim();
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• ',
                  style: baseStyle?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Expanded(
                  child: Text.rich(_parseInlineMarkdown(bulletText, baseStyle)),
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text.rich(_parseInlineMarkdown(line, baseStyle)),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  bool _isStandaloneSectionTitle(String line) {
    const titles = {
      'features',
      'bug fixes',
      'melhorias',
      'refactoring',
      'mudanças de quebra',
      'ci',
    };
    return titles.contains(line.toLowerCase());
  }

  TextSpan _parseInlineMarkdown(String text, TextStyle? baseStyle) {
    final pattern = RegExp(r'(\*\*.*?\*\*|`[^`]+`)');
    final spans = <InlineSpan>[];
    int start = 0;

    for (final match in pattern.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      final token = match.group(0)!;
      if (token.startsWith('**') && token.endsWith('**') && token.length > 4) {
        final inner = token.substring(2, token.length - 2).replaceAll('`', '');
        spans.add(
          TextSpan(
            text: inner,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      } else if (token.startsWith('`') &&
          token.endsWith('`') &&
          token.length > 2) {
        spans.add(TextSpan(text: token.substring(1, token.length - 1)));
      } else {
        spans.add(TextSpan(text: token));
      }
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }

    return TextSpan(style: baseStyle, children: spans);
  }
}
