import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/local.dart';
import '../utils/constantes.dart';
import '../utils/formatadores.dart';
import '../utils/geo.dart';

/// Mapa real em 3D (MapLibre GL + imagens de satélite + prédios em 3D).
/// Não exige chave de API. Mostra um marcador para cada local recebido.
class MapaWebView extends StatefulWidget {
  final String cidade;
  final List<Local> locais;
  final Local? destaque;
  final bool satelite;

  /// Muda a cada toque em "centralizar" para recarregar a vista.
  final int tick;

  const MapaWebView({
    super.key,
    required this.cidade,
    required this.locais,
    this.destaque,
    this.satelite = true,
    this.tick = 0,
  });

  @override
  State<MapaWebView> createState() => _MapaWebViewState();
}

class _MapaWebViewState extends State<MapaWebView> {
  late final WebViewController _controller;
  String _assinatura = '';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController();
    if (!kIsWeb) {
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    }
    _carregar();
  }

  @override
  void didUpdateWidget(covariant MapaWebView antigo) {
    super.didUpdateWidget(antigo);
    if (_gerarAssinatura() != _assinatura) _carregar();
  }

  /// Resume tudo que muda o desenho do mapa (evita recarregar à toa).
  String _gerarAssinatura() {
    final locais = widget.locais
        .map((l) => '${l.id}|${l.nome}|${l.categoria}|${l.latitude}|${l.longitude}')
        .join(',');
    return '${widget.cidade}|${widget.satelite}|${widget.tick}|'
        '${widget.destaque?.id}|$locais';
  }

  void _carregar() {
    _assinatura = _gerarAssinatura();

    final centro = kCentroCidade[widget.cidade] ?? kCentroCidade.values.first;
    final marcadores = widget.locais.map((l) {
      final c = coordenadasDe(l);
      return <String, dynamic>{
        'n': l.nome,
        'c': l.categoria,
        'k': formatarKm(l.distancia),
        'lat': c[0],
        'lng': c[1],
      };
    }).toList();

    final destaque = widget.destaque == null
        ? -1
        : widget.locais.indexWhere((l) => l.id == widget.destaque!.id);

    _controller.loadHtmlString(
      gerarHtmlMapa(
        centro: centro,
        marcadores: marcadores,
        destaque: destaque,
        satelite: widget.satelite,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: _controller,
      // O mapa recebe os gestos mesmo dentro de listas/rolagens.
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
  }
}

/// Gera a página HTML do mapa. [centro] = [latitude, longitude].
String gerarHtmlMapa({
  required List<double> centro,
  required List<Map<String, dynamic>> marcadores,
  required int destaque,
  required bool satelite,
}) {
  const modelo = r'''
<!doctype html>
<html><head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<link rel="stylesheet" href="https://unpkg.com/maplibre-gl@5.6.0/dist/maplibre-gl.css">
<script src="https://unpkg.com/maplibre-gl@5.6.0/dist/maplibre-gl.js"></script>
<style>
  html,body,#m{margin:0;height:100%;background:#05070f}
  .maplibregl-popup-content{font:13px sans-serif;padding:8px 12px}
</style>
</head><body><div id="m"></div>
<script>
const marcadores = __MARCADORES__;
const centro = __CENTRO__;      // [longitude, latitude]
const destaque = __DESTAQUE__;  // índice do marcador em destaque (-1 = nenhum)
const satelite = __SATELITE__;

const estiloSatelite = {
  version: 8,
  glyphs: 'https://tiles.openfreemap.org/fonts/{fontstack}/{range}.pbf',
  sources: {
    sat: {
      type: 'raster', tileSize: 256, maxzoom: 19,
      tiles: ['https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'],
      attribution: 'Imagens: Esri, Maxar, Earthstar Geographics | Dados: OpenStreetMap'
    },
    omt: { type: 'vector', url: 'https://tiles.openfreemap.org/planet' }
  },
  projection: { type: 'globe' },
  layers: [
    { id: 'sat', type: 'raster', source: 'sat' },
    { id: 'predios', type: 'fill-extrusion', source: 'omt', 'source-layer': 'building', minzoom: 14,
      paint: {
        'fill-extrusion-color': '#e9e5dc',
        'fill-extrusion-height': ['coalesce', ['get', 'render_height'], 10],
        'fill-extrusion-base': ['coalesce', ['get', 'render_min_height'], 0],
        'fill-extrusion-opacity': 0.92
      } },
    { id: 'lugares', type: 'symbol', source: 'omt', 'source-layer': 'place',
      layout: { 'text-field': ['get', 'name'], 'text-font': ['Noto Sans Regular'], 'text-size': 13 },
      paint: { 'text-color': '#ffffff', 'text-halo-color': '#000000', 'text-halo-width': 1.4 } }
  ]
};

const map = new maplibregl.Map({
  container: 'm',
  style: satelite ? estiloSatelite : 'https://tiles.openfreemap.org/styles/liberty',
  center: [-30, 10], zoom: 1.4, pitch: 0, bearing: 0, maxPitch: 85
});
if (!satelite) {
  map.on('style.load', () => { try { map.setProjection({type: 'globe'}); } catch (e) {} });
}
map.addControl(new maplibregl.NavigationControl({visualizePitch: true}), 'top-left');

// Um marcador para cada local (azul = local em destaque).
const objetos = marcadores.map((m, i) => {
  const caixa = document.createElement('div');
  const nome = document.createElement('b');
  nome.textContent = m.n;
  caixa.appendChild(nome);
  caixa.appendChild(document.createElement('br'));
  caixa.appendChild(document.createTextNode(m.c + ' · ' + m.k));
  const popup = new maplibregl.Popup({offset: 28, closeButton: false}).setDOMContent(caixa);
  return new maplibregl.Marker({color: i === destaque ? '#1976d2' : '#d9534f'})
    .setLngLat([m.lng, m.lat]).setPopup(popup).addTo(map);
});

const pronto = new Promise(res => { map.once('load', res); setTimeout(res, 8000); });
pronto.then(() => {
  map.once('moveend', () => {
    const o = objetos[destaque >= 0 ? destaque : 0];
    if (o && !o.getPopup().isOpen()) o.togglePopup();
  });
  if (destaque >= 0) {
    map.flyTo({center: [marcadores[destaque].lng, marcadores[destaque].lat],
      zoom: 17, pitch: 60, bearing: 30, duration: 4000, essential: true});
  } else if (marcadores.length > 1) {
    const limites = new maplibregl.LngLatBounds();
    marcadores.forEach(m => limites.extend([m.lng, m.lat]));
    map.fitBounds(limites, {padding: 70, maxZoom: 15.5, pitch: 55, bearing: 20,
      duration: 4000, essential: true});
  } else {
    map.flyTo({center: centro, zoom: 14, pitch: 55, bearing: 20,
      duration: 4000, essential: true});
  }
});
</script></body></html>''';

  // `<` vira < para o JSON nunca fechar a tag <script> por engano.
  final json = jsonEncode(marcadores).replaceAll('<', r'<');

  return modelo
      .replaceAll('__MARCADORES__', json)
      .replaceAll('__CENTRO__', jsonEncode([centro[1], centro[0]]))
      .replaceAll('__DESTAQUE__', '$destaque')
      .replaceAll('__SATELITE__', '$satelite');
}
