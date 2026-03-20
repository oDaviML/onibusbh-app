# Changelog

## [1.3.0] - 2026-03-20

### Features

- Adicionar acordeão de sentidos nas paradas — quando a API retorna a mesma linha com direção Ida e Volta, é exibido um acordeão expansível com as opções de sentido e suas respectivas previsões de chegada
- Criar modelo `PredictionGroup` para agrupar previsões por `routeId`
- Criar widget `PredictionAccordionTile` para exibir o acordeão de sentidos
- Criar `arrival_bubbles.dart` componentizado com `ArrivalBubble`, `ArrivalBubblesColumn`, `MapControlButton` e `MapControlsColumn`
- Configurar GitHub Actions para release automático com CHANGELOG

### Bug Fixes

- Corrigir mapeamento `directionId` no `PredictionResponseDto` — o JSON da API usa `"directionId"`, mas o modelo Dart lia `"direction"`
- Corrigir mapa mutável em `PredictionGroup.groupPredictions()` — não tentava mais mutar um `const Map`
- Corrigir filtro de direction nas arrival bubbles no `StopTrackingScreen` — agora filtra por `routeId` e `direction` corretamente
- Corrigir `MaterialLocalizations` no `UpdateDialog` — mover `_checkForUpdate` do `main.dart` para `ScaffoldWithNavBar`

### Refactoring

- Remover classes locais `_ArrivalBubble` e `_MapControlButton` do `StopTrackingScreen` (757 → 503 linhas)
- Componentizar controles do mapa em `arrival_bubbles.dart`

### CI

- Criar `release.yml` — build do APK e criação de GitHub Release ao fazer tag
- Criar `dart-analyze.yml` — análise estática com `flutter analyze`
