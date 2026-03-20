import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'custom_bottom_navigation_bar.dart';
import '../../data/providers/update_providers.dart';
import 'update_dialog.dart';

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  static final forceHide = ValueNotifier<bool>(false);

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  @override
  void initState() {
    super.initState();
    _requestInitialLocationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkForUpdate());
    ScaffoldWithNavBar.forceHide.addListener(_onForceHideChanged);
  }

  @override
  void dispose() {
    ScaffoldWithNavBar.forceHide.removeListener(_onForceHideChanged);
    super.dispose();
  }

  void _onForceHideChanged() {
    setState(() {});
  }

  Future<void> _requestInitialLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  Future<void> _checkForUpdate() async {
    final release = await ref.read(updateCheckProvider.future);
    if (release != null && mounted) {
      UpdateDialog.show(context, release);
    }
  }

  void _onItemTapped(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  bool _shouldHideNavBar() {
    if (ScaffoldWithNavBar.forceHide.value) return true;
    final location = GoRouterState.of(context).uri.toString();
    return location.contains('/lines/details');
  }

  @override
  Widget build(BuildContext context) {
    final hideNavBar = _shouldHideNavBar();

    return Scaffold(
      extendBody: true,
      body: widget.navigationShell,
      bottomNavigationBar: AnimatedSlide(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        offset: hideNavBar ? const Offset(0, 1.5) : Offset.zero,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: hideNavBar ? 0.0 : 1.0,
          child: IgnorePointer(
            ignoring: hideNavBar,
            child: CustomBottomNavigationBar(
              currentIndex: widget.navigationShell.currentIndex,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
