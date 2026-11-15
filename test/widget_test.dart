import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onibusbh/data/models/line_summary_dto.dart';
import 'package:onibusbh/data/models/stop_dto.dart';
import 'package:onibusbh/data/models/vehicle_position_dto.dart';
import 'package:onibusbh/ui/features/lines/widgets/line_itinerary_view.dart';

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
}
