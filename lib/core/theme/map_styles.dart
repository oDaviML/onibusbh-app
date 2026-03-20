class MapStyles {
  static const String light =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
  static const String dark =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';

  static String getTileUrl(bool isDark) => isDark ? dark : light;

  static const List<String> subdomains = ['a', 'b', 'c', 'd'];
}
