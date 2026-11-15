class LineTimetableDto {
  final String routeId;
  final String shortName;
  final String longName;
  final String system;
  final List<TimetableDirectionDto> directions;

  const LineTimetableDto({
    required this.routeId,
    required this.shortName,
    required this.longName,
    this.system = 'BHTRANS',
    this.directions = const [],
  });

  bool get isMetropolitan =>
      system.toUpperCase() == 'OTIMO' || routeId.startsWith('otimo_');

  factory LineTimetableDto.fromJson(Map<String, dynamic> json) {
    final dirsRaw = json['directions'] as List<dynamic>? ?? const [];
    return LineTimetableDto(
      routeId: json['routeId']?.toString() ?? '',
      shortName: json['shortName']?.toString() ?? '',
      longName: json['longName']?.toString() ?? '',
      system: json['system']?.toString() ?? 'BHTRANS',
      directions: dirsRaw
          .map((e) => TimetableDirectionDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TimetableDirectionDto {
  final int directionId;
  final String description;
  final List<TimetableServiceDto> services;

  const TimetableDirectionDto({
    required this.directionId,
    required this.description,
    this.services = const [],
  });

  factory TimetableDirectionDto.fromJson(Map<String, dynamic> json) {
    final servicesRaw = json['services'] as List<dynamic>? ?? const [];
    return TimetableDirectionDto(
      directionId: (json['directionId'] as num?)?.toInt() ?? 0,
      description: json['description']?.toString() ?? '',
      services: servicesRaw
          .map((e) => TimetableServiceDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TimetableServiceDto {
  final String serviceId;
  final String name;
  final String category;
  final List<bool> days;
  final List<TimetableDepartureDto> departures;

  const TimetableServiceDto({
    required this.serviceId,
    required this.name,
    this.category = 'WEEKDAY',
    this.days = const [],
    this.departures = const [],
  });

  String get shortCategoryLabel {
    switch (category.toUpperCase()) {
      case 'SATURDAY':
        return 'Sábados';
      case 'SUNDAY':
        return 'Domingos';
      default:
        return 'Dias Úteis';
    }
  }

  factory TimetableServiceDto.fromJson(Map<String, dynamic> json) {
    final daysRaw = json['days'] as List<dynamic>? ?? const [];
    final depsRaw = json['departures'] as List<dynamic>? ?? const [];
    return TimetableServiceDto(
      serviceId: json['serviceId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      category: json['category']?.toString() ?? 'WEEKDAY',
      days: daysRaw.map((e) => e == true).toList(),
      departures: depsRaw
          .map((e) => TimetableDepartureDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TimetableDepartureDto {
  final String departureTime;
  final String? arrivalTime;
  final String? variantShortName;
  final String? headsign;
  final bool accessible;
  final bool extra;

  const TimetableDepartureDto({
    required this.departureTime,
    this.arrivalTime,
    this.variantShortName,
    this.headsign,
    this.accessible = false,
    this.extra = false,
  });

  int? get departureMinutesFromMidnight {
    final parts = departureTime.split(':');
    if (parts.length < 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return h * 60 + m;
  }

  String get hourLabel {
    final parts = departureTime.split(':');
    if (parts.isEmpty) return departureTime;
    return '${parts[0].padLeft(2, '0')}h';
  }

  factory TimetableDepartureDto.fromJson(Map<String, dynamic> json) {
    return TimetableDepartureDto(
      departureTime: json['departureTime']?.toString() ?? '',
      arrivalTime: json['arrivalTime']?.toString(),
      variantShortName: json['variantShortName']?.toString(),
      headsign: json['headsign']?.toString(),
      accessible: json['accessible'] == true,
      extra: json['extra'] == true,
    );
  }
}
