import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

abstract final class MapStyles {
  static const String osmTileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  static const String userAgentPackageName = 'com.onibusbh.onibusbh_app';

  static const String light = osmTileUrl;
  static const String dark = osmTileUrl;
  static const List<String> subdomains = [];

  static String getTileUrl(bool isDark) => osmTileUrl;

  static const ColorFilter _darkTileColorFilter = ColorFilter.matrix(<double>[
    -0.85,  0.00,  0.00, 0.0, 225.0,
     0.00, -0.82,  0.00, 0.0, 220.0,
     0.00,  0.00, -0.75, 0.0, 215.0,
     0.00,  0.00,  0.00, 1.0,   0.0,
  ]);

  static Widget buildTileLayer({required bool isDark}) {
    return TileLayer(
      urlTemplate: osmTileUrl,
      userAgentPackageName: userAgentPackageName,
      maxZoom: 19,
      tileBuilder: isDark
          ? (context, tileWidget, tile) => ColorFiltered(
                colorFilter: _darkTileColorFilter,
                child: tileWidget,
              )
          : null,
    );
  }
}
