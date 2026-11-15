import 'package:json_annotation/json_annotation.dart';

part 'stop_dto.g.dart';

@JsonSerializable()
class StopDto {
  final String id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final int? stopSequence;
  final String? streetName;
  final int? travelTimeSeconds;
  final String system;

  const StopDto({
    required this.id,
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    this.stopSequence,
    this.streetName,
    this.travelTimeSeconds,
    this.system = 'BHTRANS',
  });

  bool get isMetropolitan =>
      system.toUpperCase() == 'OTIMO' || id.startsWith('otimo_');

  String get shortSystemLabel => isMetropolitan ? 'Ótimo' : 'BHTrans';

  String get resolvedStreetName {
    if (streetName != null && streetName!.trim().isNotEmpty) {
      return streetName!.trim();
    }
    final trimmed = name.trim();
    final commaIdx = trimmed.indexOf(',');
    if (commaIdx > 2) {
      return trimmed.substring(0, commaIdx).trim();
    }
    final dashIdx = trimmed.indexOf(' - ');
    if (dashIdx > 2) {
      return trimmed.substring(0, dashIdx).trim();
    }
    return trimmed.isEmpty ? 'Via sem nome' : trimmed;
  }

  factory StopDto.fromJson(Map<String, dynamic> json) =>
      _$StopDtoFromJson(json);

  Map<String, dynamic> toJson() => _$StopDtoToJson(this);
}
