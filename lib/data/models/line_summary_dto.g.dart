// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_summary_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LineSummaryDto _$LineSummaryDtoFromJson(Map<String, dynamic> json) =>
    LineSummaryDto(
      routeId: json['routeId'] as String,
      shortName: json['shortName'] as String,
      longName: json['longName'] as String,
      color: json['color'] as String?,
      textColor: json['textColor'] as String?,
      isBidirectional: json['isBidirectional'] as bool? ?? false,
      stopCount: (json['stopCount'] as num?)?.toInt() ?? 0,
      avgTravelTime: (json['avgTravelTime'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$LineSummaryDtoToJson(LineSummaryDto instance) =>
    <String, dynamic>{
      'routeId': instance.routeId,
      'shortName': instance.shortName,
      'longName': instance.longName,
      'color': instance.color,
      'textColor': instance.textColor,
      'isBidirectional': instance.isBidirectional,
      'stopCount': instance.stopCount,
      'avgTravelTime': instance.avgTravelTime,
    };
