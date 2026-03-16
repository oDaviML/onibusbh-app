# Regras de Desenvolvimento Flutter - Ônibus BH

Este documento consolida as diretrizes técnicas para o desenvolvimento do aplicativo Ônibus BH. Todas as modificações no código devem ser precedidas ou guias por estas regras.

## 1. Pesquisa e Documentação Atualizada (CRÍTICO)
No ecossistema Flutter/Dart, pacotes e abordagens mudam rapidamente (especialmente ferramentas como Riverpod, GoRouter e mapas).
- **Ação:** Sempre utilize o **context7** (via MCP `mcp_context7_resolve-library-id` e `mcp_context7_query-docs`) para consultar documentações oficiais, padrões atualizados e APIs de bibliotecas antes de codificar integrações e gerência de estado.
- **Ação Alternativa:** Se o context7 não possuir o pacote desejado ou estiver desatualizado, utilize a **busca no Google (search_web)** para checar _issues_ recentes no GitHub, acessar as abstrações no pub.dev e ver as soluções modernas no StackOverflow.
- **Regra:** Nunca assuma versões antigas. Confirme sempre a sintaxe padrão atual do ecossistema Flutter 3+.

## 2. Abordagem Especialista (Expertise Flutter Moderno)
- **Skill Referenciada:** `flutter-expert`
- **Regra:** Aplique sempre as melhores práticas do core do Flutter. Estruture a lógica mantendo baixo acoplamento. Use métodos modernos de Injeção de Dependências e injete controllers preferencialmente por Singletons otimizados do pacote nativo ou Riverpod/Bloc.

## 3. Planejamento de Arquitetura Limpa
- **Skill Referenciada:** `flutter-architecting-apps`
- **Regra:** Separe rigorosamente a aplicação em camadas lógicas:
  - `UI` (Telas e Componentes Visuais)
  - `Logic/Business` (State Management, Controllers)
  - `Data` (Repositórios, DTOs vindos do `api-documentation.yaml`)
- A comunicação entre UI e Data nunca deve ser direta.

## 4. Estado da Aplicação e Reatividade
- **Skill Referenciada:** `flutter-managing-state`
- **Regra:** O aplicativo consome endpoints dinâmicos (`vehicles` por linha, `predictions` por parada). O estado deve reagir corretamente aos "streamings" constantes (polling via Future ou WebSocket, se aplicável) sem reconstruir a UI inteira (ex: widget de mapa pesado). 
- Construa estados locais para dados efêmeros (como toggle de Sentido da Rota) e estados globais/view models para dados consumidos em múltiplas telas (veículos).

## 5. UI Adaptativa e Layouts Limpos
- **Skill Referenciada:** `flutter-building-layouts`
- **Regra:** Faça uso eficiente das _Constraints_ do Flutter (LayoutBuilder, MediaQuery, SafeAreas). Evite ao máximo o erro "RenderFlex overflowed". Assegure que as BottomSheets e Drawers funcionem bem em telas longas e nos mapas com BBOX variables.

## 6. Padronização Global de Estilos
- **Skill Referenciada:** `flutter-theming-apps`
- **Regra:** Centralize cores e propriedades da tipografia em um `ThemeData`. Como a API retorna propriedades visuais das linhas (como `color` e `textColor`), utilize contrastes que garantam legibilidade com o tema do usuário (Claro / Escuro). Não codifique fontes/tamanhos "soltos" nos componentes.

## 7. Fluidez, Micro-Animações e Transições
- **Skill Referenciada:** `flutter-animating-apps`
- **Regra:** O usuário deve se sentir no controle do app através de feedbacks visuais. Insira transições suaves:
  - Animação no acordeão ao detalhar paradas.
  - Animação de direção e de movimento ("tweens") nos ícones de veículos variando seu `bearing`.
  - Transições limpas (Hero Animations) entre lista de linhas e mapa detalhado.

## 8. HTTP, Parsing e Desserialização JSON
- **Skill Referenciada:** `flutter-handling-http-and-json`
- **Regra:** O consumo de `http://localhost:8080/api/v1/*` exige abstrações de HTTP maduras (como `http` puro com clients injetáveis ou frameworks como `dio`). É imperativo o uso de try-catch isolado, log de exceção, suporte a timeouts e serialização fiel dos modais de OpenAPI previstos (lidando responsavelmente com cenários de `isError: true` no retorno).

## 9. Navegação e Deep Links (Rotas)
- **Skill Referenciada:** `flutter-implementing-navigation-and-routing`
- **Regra:** A navegação deve ser fortemente tipada e seguir configurações re-utilizáveis de Deep Links. Estruture URLs limpas para que, no futuro ou agora, o usuário possa redirecionar de volta para o mapa focado num ID específico da linha.

## 10. Cache e Performance de Rede
- **Skill Referenciada:** `flutter-caching-data`
- **Regra:** Odiamos delay no primeiro load. Realize _cache_ (Sqflite / Hive / SharedPreferences) de dados estáticos da malha (lista de linhas, contornos geométricos de rota e localizações de parada) para que o loading da UI seja ágil. Somente requisições estritamente "Real-Time" (`/predictions` e `/vehicles`) devem pular a camada de retenção local.

## 11. Acessibilidade (Screen Readers Focus)
- **Skill Referenciada:** `flutter-improving-accessibility`
- **Regra:** Todos os componentes cruciais da tela necessitam suporte a telas assistidas (`Semantics`). Por exemplo, os marcadores de mapa e as previsões cronológicas devem ser descritos em linguagem natural (ex: "Linha 8203, chegando em 5 minutos" em vez de ler "8203 5").

## 12. App Size e Optmização de Release
- **Skill Referenciada:** `flutter-reducing-app-size`
- **Regra:** Revise regularmente imports não utilizados e assegure que o bundle gerado do app exclua debug flags/arquiteturas não suportadas, compactando _assets_ corretamente no Build e mantendo os APKs/IPAs reduzidos.
