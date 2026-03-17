import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/stop_dto.dart';
import '../widgets/stop_details_drawer.dart';

class GlobalStopsMapScreen extends StatelessWidget {
  const GlobalStopsMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Material(
            color: isDark ? AppColors.slate800 : AppColors.surfaceLight,
            shape: const CircleBorder(),
            elevation: 2,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              color: AppColors.slate900,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: isDark ? AppColors.slate800 : AppColors.surfaceLight,
              shape: const CircleBorder(),
              elevation: 2,
              child: IconButton(
                icon: const Icon(Icons.my_location),
                color: AppColors.primary,
                onPressed: () {},
              ),
            ),
          )
        ],
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Functional Map Layer
          Positioned.fill(
            child: FlutterMap(
              options: const MapOptions(
                initialCenter: LatLng(-19.9167, -43.9345), // Belo Horizonte
                initialZoom: 14.0,
                interactionOptions: InteractionOptions(
                  flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.onibusbh',
                ),
                MarkerLayer(
                  markers: mockStops.map((stop) {
                    return Marker(
                      point: LatLng(stop.lat, stop.lon),
                      width: 40,
                      height: 40,
                      child: GestureDetector(
                        onTap: () {
                          // Show the drawer for the selected stop
                          StopDetailsDrawer.show(context, stop);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.directions_bus,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Search overlay
          Positioned(
            top: 100,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate900 : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: AppColors.slate400),
                  const SizedBox(width: 12),
                  Text(
                    'Buscar paradas próximas...',
                    style: AppTypography.display.copyWith(
                      color: AppColors.slate400,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Map Action Buttons (Zoom)
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _buildMapActionBtn(isDark, Icons.add),
                const SizedBox(height: 8),
                _buildMapActionBtn(isDark, Icons.remove),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapActionBtn(bool isDark, IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate800 : AppColors.surfaceLight,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
             color: Colors.black12,
             blurRadius: 8,
             offset: Offset(0, 2),
          )
        ],
      ),
      child: Icon(icon, color: AppColors.slate900),
    );
  }
}
