import 'package:json_annotation/json_annotation.dart';

part 'line_variant_dto.g.dart';

@JsonSerializable()
class LineVariantDto {
  final String variantLabel;
  final String? headsign;
  final int? tripCount;
  final String? shapeId;
  final int? vehicleCount;
  final String? tripId;

  const LineVariantDto({
    required this.variantLabel,
    this.headsign,
    this.tripCount,
    this.shapeId,
    this.vehicleCount,
    this.tripId,
  });

  String get displayName {
    return formatLabel(variantLabel);
  }

  static String formatLabel(String label) {
    final words = label.split('_').map((w) {
      if (w.isEmpty) return w;
      final lower = w.toLowerCase();
      final fixes = {
        'via': 'Via',
        'dos': 'dos',
        'das': 'das',
        'do': 'do',
        'da': 'da',
        'de': 'de',
        'e': 'e',
      };
      return fixes[lower] ?? '${lower[0].toUpperCase()}${lower.substring(1)}';
    }).toList();
    if (words.isNotEmpty) {
      words[0] = words[0][0].toUpperCase() + words[0].substring(1);
    }
    return words.join(' ');
  }

  factory LineVariantDto.fromJson(Map<String, dynamic> json) =>
      _$LineVariantDtoFromJson(json);

  Map<String, dynamic> toJson() => _$LineVariantDtoToJson(this);
}
