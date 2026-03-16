---
description: Workflow e Regras para Desenvolvimento Flutter (Ônibus BH)
---

# Contexto da Aplicação (Ônibus BH)

O aplicativo **Ônibus BH** tem como objetivo apresentar posições de veículos em tempo real, rotas e previsões de chegada ao usuário. Ele foca em dois fluxos primários definidos nos requisitos:

## 1. Navegação e Explorar Linhas
- **Busca**: Lista com suporte a pesquisa de linhas (Header fixo).
- **Seleção de Sentido**: Modal para linhas bidirecionais (sentidos 0 e 1).
- **Mapa da Linha (Detalhe)**: 
  - Exibe o **Trajeto (Polyline/Shape)** da rota selecionada.
  - Exibe os as **Paradas (Stops)** do trajeto.
  - Exibe os **Veículos em tempo real**, com suporte a direção/rotação via campo `bearing`.

## 2. Navegação por Pontos de Parada
- **Mapa Geral**: Visualização com **Clustering** enviando as coordenadas da tela atual (`BBOX` - Bounding Box via minLat, maxLat, minLon, maxLon).
- **Detalhes e Previsões**: Drawer (ou Accordion) listando linhas que atendem um ponto escolhido, incluindo uma timeline com previsões estimadas de chegada (ETA ou por cálculo de distância/velocidade).

# Endpoints Documentados (`api-documentation.yaml`)
A comunicação Backend-Frontend se baseia na OpenAPI (`http://localhost:8080`), consumindo:
- **Linhas**:
  - `GET /api/v1/lines?query={termo}` -> Lista e pesquisa (`LineSummaryDto`).
  - `GET /api/v1/lines/{id}/shape?direction={0|1}` -> Traçado da linha (`ShapeDto`).
  - `GET /api/v1/lines/{id}/stops?direction={0|1}` -> Paradas atreladas à linha (`StopDto`).
  - `GET /api/v1/lines/{id}/vehicles` -> Integração em tempo real (`VehiclePositionDto`).
- **Paradas**:
  - `GET /api/v1/stops?minLat=...&minLon=...&maxLat=...&maxLon=...` -> Mapa por BBOX (`StopDto`).
  - `GET /api/v1/stops/{id}/predictions` -> Previsão de chegada por linha (`PredictionResponseDto`).

---

# Regras de Desenvolvimento com Agents, Skills e MCPs

Sempre que atuar no desenvolvimento, adote a seguinte metodologia guiada pelo contexto do aplicativo e ferramentas do ecossistema Agentic:

## 1. Planejamento de Arquitetura e Bibliotecas Padrão do Mercado
- **Ação:** Antes de codar, invocar a skill `flutter-architecting-apps` para a estrutura, e a skill `flutter-expert` para definições de bibliotecas famosas e boas práticas do ecossistema.
- **Regra:** O projeto deve seguir uma separação limpa entre UI, Logics e Data. Comece definindo os DTOs em Dart a partir dos Schemas do OpenAPI para garantir integração segura.
- **Ferramentas Consolidadas:** Sempre consulte o `flutter-expert` para implementar rotas e navegação (ex: GoRouter), injeção de dependências e gerenciamento de estado avançado (ex: Riverpod/Bloc), além de melhorias de performance nas plataformas alvo.

## 2. Gerenciamento de Dependências e Ambiente
- **Ação:** Em vez de usar shell iterativamente, tire máximo proveito do **dart-mcp-server**.
- **Regra:** Use as tools `pub` do dart-mcp-server para adicionar pacotes (ex: HTTP, Maps, State Management). Após alterações amplas, chame `analyze_files` e `dart_fix` para remover warnings.

## 3. Implementação de UI, Design System e Telas
- **Ação:** Utilize o **StitchMCP** para iniciar protótipos de tela ou criar interfaces inovadoras baseadas nos endpoints (ex: Cards de previsão, mapas responsivos).
- **Ação:** Invocar as skills `flutter-theming-apps` e `flutter-building-layouts`.
- **Regra:** Construa modais modulares para a Seleção de Sentido e Drawers/Accordion interativos e suaves utilizando as melhores práticas para a exibição de horários. Para animações fluídas entre a tela de lista de linhas e o mapa focado na rota, aplique conhecimentos da skill `flutter-animating-apps`.

## 4. Estado da Aplicação e Tempo Real
- **Ação:** Invocar `flutter-managing-state` em conjunto com `flutter-expert`.
- **Regra:** Considere o constante fluxo de dados em endpoints rotineiros (visão de `vehicles` na linha e `predictions` na parada). O estado deve reagir corretamente a essas atualizações constantes sem recarregar layouts pesados (como o widget do mapa). Aplique os padrões de Riverpod/Bloc recomendados pela skill expert para manter a interface isolada das regras de negócio.

## 5. Integração com API
- **Ação:** Invocar `flutter-handling-http-and-json`.
- **Regra:** Implementar a busca com Query Parameters (`minLat`, etc) de forma reativa, debounce na pesquisa de linha, e serialização adequada para todos os DTOs OpenAPI reportados. Adicione suporte nativo ou via pacotes bem testados para parsing do geoJSON fornecido pelas polylines.

## 6. Fluxo de Execução
- Use as ferramentas do `dart-mcp-server` como `launch_app` e, em seguida, as opções de reload (`hot_reload` ou `hot_restart`) quando estiver pareando e validando as respostas em tela. Use os logs via `get_app_logs` se detectar exceções durante o parsing do JSON das previsões ou das paradas.
