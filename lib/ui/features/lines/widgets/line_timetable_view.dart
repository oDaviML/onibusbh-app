import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../data/models/line_summary_dto.dart';
import '../../../../data/models/line_timetable_dto.dart';

class LineTimetableView extends StatefulWidget {
  final LineSummaryDto line;
  final int activeDirectionId;
  final AsyncValue<LineTimetableDto> timetableAsync;
  final VoidCallback onRetry;

  const LineTimetableView({
    super.key,
    required this.line,
    required this.activeDirectionId,
    required this.timetableAsync,
    required this.onRetry,
  });

  @override
  State<LineTimetableView> createState() => _LineTimetableViewState();
}

class _LineTimetableViewState extends State<LineTimetableView> {
  int? _selectedDirectionId;
  String? _selectedServiceKey;

  @override
  void didUpdateWidget(covariant LineTimetableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeDirectionId != widget.activeDirectionId) {
      _selectedDirectionId = widget.activeDirectionId;
    }
  }

  String _todayCategory() {
    final weekday = DateTime.now().weekday;
    if (weekday == DateTime.sunday) return 'SUNDAY';
    if (weekday == DateTime.saturday) return 'SATURDAY';
    return 'WEEKDAY';
  }

  TimetableDirectionDto? _resolveDirection(LineTimetableDto timetable) {
    if (timetable.directions.isEmpty) return null;
    final desired = _selectedDirectionId ?? widget.activeDirectionId;
    for (final dir in timetable.directions) {
      if (dir.directionId == desired) return dir;
    }
    return timetable.directions.first;
  }

  TimetableServiceDto? _resolveService(TimetableDirectionDto direction) {
    if (direction.services.isEmpty) return null;
    if (_selectedServiceKey != null) {
      for (int i = 0; i < direction.services.length; i++) {
        final s = direction.services[i];
        if ('${s.serviceId}_$i' == _selectedServiceKey) return s;
      }
    }
    final today = _todayCategory();
    for (final s in direction.services) {
      if (s.category.toUpperCase() == today) return s;
    }
    return direction.services.first;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final routeColor = widget.line.routeColor;

    return widget.timetableAsync.when(
      loading: () => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: routeColor),
            const SizedBox(height: 12),
            Text(
              'Carregando quadro de horários...',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.slate500),
            ),
          ],
        ),
      ),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.schedule_outlined,
                size: 40,
                color: AppColors.slate400,
              ),
              const SizedBox(height: 12),
              Text(
                'Não foi possível carregar o quadro de horários',
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.slate900,
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: widget.onRetry,
                style: FilledButton.styleFrom(backgroundColor: routeColor),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      data: (timetable) {
        final direction = _resolveDirection(timetable);
        if (direction == null || direction.services.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Nenhum quadro de horários disponível para esta linha.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.slate500,
                ),
              ),
            ),
          );
        }

        final service = _resolveService(direction)!;
        final now = DateTime.now();
        final nowMinutes = now.hour * 60 + now.minute;

        final upcoming = <_IndexedDeparture>[];
        for (int i = 0; i < service.departures.length; i++) {
          final dep = service.departures[i];
          final mins = dep.departureMinutesFromMidnight;
          if (mins != null && mins >= nowMinutes) {
            upcoming.add(_IndexedDeparture(dep: dep, deltaMinutes: mins - nowMinutes));
            if (upcoming.length >= 3) break;
          }
        }

        final byHour = <String, List<TimetableDepartureDto>>{};
        for (final dep in service.departures) {
          byHour.putIfAbsent(dep.hourLabel, () => []).add(dep);
        }
        final nextDeparture = upcoming.isNotEmpty ? upcoming.first.dep : null;

        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.slate900 : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? AppColors.slate800 : AppColors.slate200,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (timetable.directions.length > 1) ...[
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: timetable.directions.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final d = timetable.directions[idx];
                          final selected = d.directionId == direction.directionId;
                          final dirPrefix = d.directionId == 0 ? 'Ida' : 'Volta';
                          final label = d.description.isNotEmpty
                              ? '$dirPrefix · ${d.description}'
                              : dirPrefix;
                          return ChoiceChip(
                            label: Text(label),
                            selected: selected,
                            onSelected: (_) {
                              setState(() {
                                _selectedDirectionId = d.directionId;
                                _selectedServiceKey = null;
                              });
                            },
                            selectedColor: routeColor.withValues(alpha: 0.16),
                            labelStyle: AppTypography.caption.copyWith(
                              color: selected
                                  ? routeColor
                                  : (isDark
                                        ? AppColors.slate300
                                        : AppColors.slate600),
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? routeColor
                                  : (isDark
                                        ? AppColors.slate700
                                        : AppColors.slate200),
                            ),
                            visualDensity: VisualDensity.compact,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    height: 34,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: direction.services.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final svc = direction.services[idx];
                        final key = '${svc.serviceId}_$idx';
                        final selected = svc == service;
                        return ChoiceChip(
                          label: Text(
                            '${svc.shortCategoryLabel} (${svc.departures.length})',
                          ),
                          selected: selected,
                          onSelected: (_) {
                            setState(() => _selectedServiceKey = key);
                          },
                          selectedColor: routeColor.withValues(alpha: 0.16),
                          labelStyle: AppTypography.caption.copyWith(
                            color: selected
                                ? routeColor
                                : (isDark
                                      ? AppColors.slate300
                                      : AppColors.slate600),
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: selected
                                ? routeColor
                                : (isDark
                                      ? AppColors.slate700
                                      : AppColors.slate200),
                          ),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  MediaQuery.of(context).padding.bottom + 24,
                ),
                children: [
                  _buildUpcomingCard(
                    isDark: isDark,
                    routeColor: routeColor,
                    serviceName: service.name,
                    upcoming: upcoming,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Quadro completo de saídas',
                        style: AppTypography.titleMedium.copyWith(
                          color: isDark ? Colors.white : AppColors.slate900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${service.departures.length} horários',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final entry in byHour.entries)
                    _buildHourGroup(
                      isDark: isDark,
                      routeColor: routeColor,
                      hourLabel: entry.key,
                      departures: entry.value,
                      nowMinutes: nowMinutes,
                      nextDeparture: nextDeparture,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUpcomingCard({
    required bool isDark,
    required Color routeColor,
    required String serviceName,
    required List<_IndexedDeparture> upcoming,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: routeColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.slate900.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: routeColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Próximas saídas do ponto inicial',
                  style: AppTypography.labelMedium.copyWith(
                    color: routeColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (serviceName.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              serviceName,
              style: AppTypography.caption.copyWith(color: AppColors.slate500),
            ),
          ],
          const SizedBox(height: 10),
          if (upcoming.isEmpty)
            Text(
              'Não há mais saídas previstas para hoje neste quadro.',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.slate500,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: upcoming.asMap().entries.map((entry) {
                final isFirst = entry.key == 0;
                final item = entry.value;
                final deltaLabel = item.deltaMinutes == 0
                    ? 'Agora'
                    : (item.deltaMinutes < 60
                          ? 'em ${item.deltaMinutes} min'
                          : 'em ${item.deltaMinutes ~/ 60}h${(item.deltaMinutes % 60).toString().padLeft(2, '0')}');
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isFirst
                        ? routeColor.withValues(alpha: 0.14)
                        : (isDark ? AppColors.slate800 : AppColors.slate100),
                    borderRadius: BorderRadius.circular(12),
                    border: isFirst
                        ? Border.all(color: routeColor.withValues(alpha: 0.45))
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.dep.departureTime,
                            style: AppTypography.titleMedium.copyWith(
                              color: isFirst
                                  ? routeColor
                                  : (isDark ? Colors.white : AppColors.slate900),
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (item.dep.arrivalTime != null &&
                              item.dep.arrivalTime!.isNotEmpty) ...[
                            Text(
                              ' → ${item.dep.arrivalTime}',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.slate500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                          if (item.dep.variantShortName != null &&
                              item.dep.variantShortName!.isNotEmpty) ...[
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: routeColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.dep.variantShortName!,
                                style: AppTypography.caption.copyWith(
                                  color: routeColor,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        deltaLabel,
                        style: AppTypography.caption.copyWith(
                          color: isFirst ? routeColor : AppColors.slate500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHourGroup({
    required bool isDark,
    required Color routeColor,
    required String hourLabel,
    required List<TimetableDepartureDto> departures,
    required int nowMinutes,
    required TimetableDepartureDto? nextDeparture,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.slate800 : AppColors.slate100,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(
              hourLabel,
              style: AppTypography.labelMedium.copyWith(
                color: isDark ? AppColors.slate200 : AppColors.slate700,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: departures.map((dep) {
                final mins = dep.departureMinutesFromMidnight;
                final isNext = identical(dep, nextDeparture);
                final isPast = !isNext && mins != null && mins < nowMinutes;

                return Tooltip(
                  message: [
                    if (dep.headsign != null && dep.headsign!.isNotEmpty)
                      dep.headsign!,
                    if (dep.arrivalTime != null && dep.arrivalTime!.isNotEmpty)
                      'Chegada prevista: ${dep.arrivalTime}',
                  ].join(' · '),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: isNext
                          ? routeColor
                          : (isDark ? AppColors.slate900 : Colors.white),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isNext
                            ? routeColor
                            : (isDark ? AppColors.slate700 : AppColors.slate200),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dep.departureTime,
                          style: AppTypography.labelMedium.copyWith(
                            color: isNext
                                ? Colors.white
                                : (isPast
                                      ? AppColors.slate400
                                      : (isDark
                                            ? Colors.white
                                            : AppColors.slate900)),
                            fontWeight: isNext
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                        if (dep.variantShortName != null &&
                            dep.variantShortName!.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            dep.variantShortName!,
                            style: AppTypography.caption.copyWith(
                              fontSize: 10,
                              color: isNext
                                  ? Colors.white.withValues(alpha: 0.9)
                                  : routeColor,
                            ),
                          ),
                        ],
                        if (dep.accessible) ...[
                          const SizedBox(width: 3),
                          Icon(
                            Icons.accessible_rounded,
                            size: 12,
                            color: isNext
                                ? Colors.white.withValues(alpha: 0.9)
                                : AppColors.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _IndexedDeparture {
  final TimetableDepartureDto dep;
  final int deltaMinutes;

  const _IndexedDeparture({
    required this.dep,
    required this.deltaMinutes,
  });
}
