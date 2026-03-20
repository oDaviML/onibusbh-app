import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'data/providers/favorites_providers.dart';
import 'data/providers/theme_provider.dart';
import 'data/providers/update_providers.dart';
import 'ui/widgets/update_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: const OnibusBhApp(),
    ),
  );
}

class OnibusBhApp extends ConsumerStatefulWidget {
  const OnibusBhApp({super.key});

  @override
  ConsumerState<OnibusBhApp> createState() => _OnibusBhAppState();
}

class _OnibusBhAppState extends ConsumerState<OnibusBhApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
  }

  Future<void> _checkForUpdate() async {
    final release = await ref.read(updateCheckProvider.future);
    if (release != null && mounted) {
      UpdateDialog.show(context, release);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Ônibus BH',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}
