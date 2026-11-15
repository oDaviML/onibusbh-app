import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onibusbh/data/models/github_release.dart';
import 'package:onibusbh/data/models/line_summary_dto.dart';
import 'package:onibusbh/data/models/line_timetable_dto.dart';
import 'package:onibusbh/data/models/stop_dto.dart';
import 'package:onibusbh/data/models/vehicle_position_dto.dart';
import 'package:onibusbh/ui/features/lines/widgets/line_itinerary_view.dart';
import 'package:onibusbh/ui/features/lines/widgets/line_timetable_view.dart';
import 'package:onibusbh/ui/widgets/update_dialog.dart';

void main() {
  group('DTO helpers', () {
    test('StopDto resolves street names cleanly', () {
      const explicitStreet = StopDto(
        id: '100',
        name: 'Ponto X',
        latitude: -19.9,
        longitude: -43.9,
        streetName: 'Avenida Afonso Pena',
      );
      const commaParsed = StopDto(
        id: '101',
        name: 'Avenida Amazonas, 1200',
        latitude: -19.9,
        longitude: -43.9,
      );
      const otimoStop = StopDto(
        id: 'otimo_55',
        name: 'BR-040 - Bairro',
        latitude: -19.9,
        longitude: -43.9,
        system: 'OTIMO',
      );

      expect(explicitStreet.resolvedStreetName, 'Avenida Afonso Pena');
      expect(commaParsed.resolvedStreetName, 'Avenida Amazonas');
      expect(otimoStop.resolvedStreetName, 'BR-040');
      expect(otimoStop.isMetropolitan, isTrue);
      expect(otimoStop.shortSystemLabel, 'Ótimo');
    });

    test('LineSummaryDto identifies metropolitan system and formats price', () {
      const otimoLine = LineSummaryDto(
        routeId: 'otimo_4030',
        shortName: '4030',
        longName: 'Justinopolis / Belo Horizonte',
        system: 'OTIMO',
        price: 7.75,
      );
      const bhtransLine = LineSummaryDto(
        routeId: '5106',
        shortName: '5106',
        longName: 'Bandeirantes / BH Shopping',
      );

      expect(otimoLine.isMetropolitan, isTrue);
      expect(otimoLine.shortSystemLabel, 'Ótimo');
      expect(otimoLine.formattedPrice, 'R\$ 7,75');
      expect(bhtransLine.isMetropolitan, isFalse);
      expect(bhtransLine.shortSystemLabel, 'BHTrans');
      expect(bhtransLine.formattedPrice, isNull);
    });
  });

  group('LineItineraryView widget', () {
    const sampleLine = LineSummaryDto(
      routeId: '5106',
      shortName: '5106',
      longName: 'Bandeirantes / BH Shopping',
      system: 'BHTRANS',
    );

    const sampleStops = [
      StopDto(
        id: 's1',
        name: 'Avenida Afonso Pena, 100',
        latitude: -19.916,
        longitude: -43.934,
        stopSequence: 1,
        streetName: 'Avenida Afonso Pena',
        travelTimeSeconds: 0,
      ),
      StopDto(
        id: 's2',
        name: 'Avenida Afonso Pena, 500',
        latitude: -19.919,
        longitude: -43.936,
        stopSequence: 2,
        streetName: 'Avenida Afonso Pena',
        travelTimeSeconds: 180,
      ),
      StopDto(
        id: 's3',
        name: 'Rua da Bahia, 900',
        latitude: -19.923,
        longitude: -43.939,
        stopSequence: 3,
        streetName: 'Rua da Bahia',
        travelTimeSeconds: 420,
      ),
    ];

    const sampleVehicles = [
      VehiclePositionDto(
        vehicleId: 'V101',
        latitude: -19.919,
        longitude: -43.936,
        currentStopSequence: 2,
      ),
    ];

    testWidgets(
      'renders Parada a Parada and switches to Rua por Rua with live vehicle badge',
      (WidgetTester tester) async {
        StopDto? focusedStop;
        StopDto? openedStop;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LineItineraryView(
                line: sampleLine,
                stops: sampleStops,
                vehicles: sampleVehicles,
                isLoading: false,
                onRetry: () {},
                onFocusStopOnMap: (stop) => focusedStop = stop,
                onOpenStopPredictions: (stop) => openedStop = stop,
              ),
            ),
          ),
        );

        expect(find.text('Parada a Parada'), findsOneWidget);
        expect(find.text('Rua por Rua'), findsOneWidget);
        expect(find.text('Avenida Afonso Pena, 100'), findsOneWidget);
        expect(find.text('Rua da Bahia, 900'), findsOneWidget);
        expect(find.text('Veículo V101 aqui'), findsOneWidget);

        await tester.tap(find.text('Rua por Rua'));
        await tester.pumpAndSettle();

        expect(find.text('Avenida Afonso Pena'), findsWidgets);
        expect(find.text('Rua da Bahia'), findsOneWidget);
        expect(find.text('1 ônibus aqui'), findsOneWidget);

        await tester.tap(find.text('Parada a Parada'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Previsões neste ponto').first);
        await tester.pump();
        expect(openedStop?.id, 's1');

        await tester.tap(find.text('Ver no mapa').first);
        await tester.pump();
        expect(focusedStop?.id, 's1');
      },
    );
  });

  group('LineTimetableView', () {
    testWidgets(
      'renders direction and service tabs, departures, variant badge and switches service on tap',
      (tester) async {
        const sampleLine = LineSummaryDto(
          routeId: '5102',
          shortName: '5102',
          longName: 'UFMG / Centro',
          color: '0F62FE',
          system: 'BHTRANS',
        );

        const timetable = LineTimetableDto(
          routeId: '5102',
          shortName: '5102',
          longName: 'UFMG / Centro',
          system: 'BHTRANS',
          directions: [
            TimetableDirectionDto(
              directionId: 0,
              description: 'Centro',
              services: [
                TimetableServiceDto(
                  serviceId: 'uteis',
                  name: 'Dias Úteis',
                  category: 'WEEKDAY',
                  days: [false, true, true, true, true, true, false],
                  departures: [
                    TimetableDepartureDto(
                      departureTime: '05:30',
                      arrivalTime: '06:10',
                      headsign: 'Centro',
                    ),
                    TimetableDepartureDto(
                      departureTime: '06:15',
                      arrivalTime: '06:55',
                      variantShortName: '5102A',
                      headsign: 'Via Serra',
                      accessible: true,
                    ),
                  ],
                ),
                TimetableServiceDto(
                  serviceId: 'sab',
                  name: 'Sábados',
                  category: 'SATURDAY',
                  days: [false, false, false, false, false, false, true],
                  departures: [
                    TimetableDepartureDto(
                      departureTime: '08:00',
                      arrivalTime: '08:40',
                      headsign: 'Centro',
                    ),
                  ],
                ),
              ],
            ),
            TimetableDirectionDto(
              directionId: 1,
              description: 'Bairro',
              services: [
                TimetableServiceDto(
                  serviceId: 'uteis',
                  name: 'Dias Úteis',
                  category: 'WEEKDAY',
                  days: [false, true, true, true, true, true, false],
                  departures: [
                    TimetableDepartureDto(
                      departureTime: '07:00',
                      headsign: 'Bairro',
                    ),
                  ],
                ),
              ],
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LineTimetableView(
                line: sampleLine,
                activeDirectionId: 0,
                timetableAsync: const AsyncData(timetable),
                onRetry: () {},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Ida · Centro'), findsOneWidget);
        expect(find.text('Volta · Bairro'), findsOneWidget);
        expect(find.text('Dias Úteis (2)'), findsOneWidget);
        expect(find.text('Sábados (1)'), findsOneWidget);
        expect(find.text('05:30'), findsWidgets);
        expect(find.text('06:15'), findsWidgets);
        expect(find.text('5102A'), findsWidgets);
        expect(find.text('08:00'), findsNothing);

        await tester.tap(find.text('Sábados (1)'));
        await tester.pumpAndSettle();

        expect(find.text('08:00'), findsWidgets);
        expect(find.text('05:30'), findsNothing);
      },
    );
  });

  group('GitHubRelease & UpdateDialog', () {
    test('normalizeBody converts escaped newlines and percent signs', () {
      const raw =
          '### Features%0A- Novo **Quadro de Horários** (`100%25`)%0A### Bug Fixes%0A- Corrigir ETA';
      final normalized = GitHubRelease.normalizeBody(raw);

      expect(normalized.contains('%0A'), isFalse);
      expect(normalized.contains('%25'), isFalse);
      expect(
        normalized,
        '### Features\n- Novo **Quadro de Horários** (`100%`)\n### Bug Fixes\n- Corrigir ETA',
      );
    });

    testWidgets(
      'UpdateDialog renders normalized sections and bullets without literal %0A or markdown markers',
      (tester) async {
        const release = GitHubRelease(
          tagName: 'v2.2.0',
          name: 'Onibus BH v2.2.0',
          body:
              '### Features%0A- Adicionar aba **Horários**%0A### Bug Fixes%0A- Exibir `Agora` quando <= 0 min',
          apkDownloadUrl: 'https://example.com/app.apk',
          comparableVersion: 2020000,
        );

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(body: UpdateDialog(release: release)),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Features'), findsOneWidget);
        expect(find.text('Bug Fixes'), findsOneWidget);
        expect(find.text('Adicionar aba Horários'), findsOneWidget);
        expect(find.text('Exibir Agora quando <= 0 min'), findsOneWidget);
        expect(find.textContaining('%0A'), findsNothing);
        expect(find.textContaining('###'), findsNothing);
      },
    );
  });
}
