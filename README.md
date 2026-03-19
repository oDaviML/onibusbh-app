# Onibus BH

Aplicativo mobile para acompanhamento de onibus em tempo real em Belo Horizonte.

## Funcionalidades

- **Diretorio de linhas** -- Busca e visualizacao de todas as linhas de onibus disponiveis
- **Mapa de rotas** -- Trajeto da linha no mapa com paradas e posicao dos veiculos em tempo real
- **Mapa global de paradas** -- Visualizacao de todas as paradas da cidade
- **Rastreamento de parada** -- Previsao de chegada dos proximos onibus em uma parada
- **Favoritos** -- Linhas e paradas favoritas salvas localmente

## Stack tecnica

- **Flutter** 3.x / Dart 3.11+
- **State management:** Riverpod (flutter_riverpod + riverpod_generator)
- **Navegacao:** GoRouter com StatefulShellRoute
- **HTTP:** Dio
- **Mapas:** flutter_map com tiles CartoDB
- **Geolocalizacao:** geolocator
- **Persistencia local:** SharedPreferences
- **Serializacao:** Freezed + json_serializable

## Arquitetura

O projeto segue uma arquitetura em camadas:

```
lib/
  core/          # Configuracoes globais (rede, roteamento, tema)
  data/          # Camada de dados (models, repositories, providers)
  ui/            # Interface (telas, widgets)
```

- **Models** sao classes imutaveis geradas com Freezed
- **Repositories** encapsulam chamadas HTTP via ApiClient
- **Providers** (Riverpod) expoem os dados dos repositories para a UI

## API

A aplicacao consome a API em `https://busapi.davimartinslage.com.br/`

## Pre-requisitos

- Flutter SDK 3.x
- Java 17 (para builds Android)

