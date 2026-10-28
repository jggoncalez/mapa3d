import 'dart:async';

import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../widgets/barra_navegacao.dart';
import '../widgets/mapa_web_view.dart';
import 'resultados_screen.dart';

/// Tela 1 — Mapa principal (entrada da aplicação).
/// Cidade selecionada, campo de pesquisa, mapa com marcadores e botão de resultados.
class MapaScreen extends StatefulWidget {
  /// Usados quando a tela é aberta por "Ver no mapa" (tela de detalhes).
  final String? cidadeInicial;
  final Local? destaque;

  const MapaScreen({super.key, this.cidadeInicial, this.destaque});

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  final LocalService _service = LocalService();
  final TextEditingController _pesquisa = TextEditingController();

  late String _cidade = widget.cidadeInicial ?? kCidades.first;
  bool _satelite = true;
  int _tick = 0;

  List<Local> _locais = [];
  bool _carregando = true;
  String? _erro;
  StreamSubscription<List<Local>>? _assinatura;

  @override
  void initState() {
    super.initState();
    _assinatura = _service.listarLocais().listen(
      (locais) {
        if (!mounted) return;
        setState(() {
          _locais = locais;
          _carregando = false;
          _erro = null;
        });
      },
      onError: (Object e) {
        if (!mounted) return;
        setState(() {
          _carregando = false;
          _erro = 'Erro ao carregar os locais.';
        });
      },
    );
  }

  @override
  void dispose() {
    _assinatura?.cancel();
    _pesquisa.dispose();
    super.dispose();
  }

  void _abrirResultados() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResultadosScreen(
          cidade: _cidade,
          pesquisa: _pesquisa.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final daCidade = _locais.where((l) => l.cidade == _cidade).toList();
    final destaque =
        (widget.destaque != null && widget.destaque!.cidade == _cidade)
            ? widget.destaque
            : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ---- cidade selecionada ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 28),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cidade selecionada', style: tema.textTheme.labelSmall),
                      PopupMenuButton<String>(
                        tooltip: 'Selecionar cidade',
                        initialValue: _cidade,
                        onSelected: (c) => setState(() {
                          _cidade = c;
                          _tick++;
                        }),
                        itemBuilder: (_) => kCidades
                            .map((c) => PopupMenuItem<String>(value: c, child: Text(c)))
                            .toList(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _cidade,
                              style: tema.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const Icon(Icons.keyboard_arrow_down),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ---- pesquisa ----
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: TextField(
                controller: _pesquisa,
                textInputAction: TextInputAction.search,
                onSubmitted: (_) => _abrirResultados(),
                decoration: InputDecoration(
                  hintText: 'Buscar locais, endereços ou categorias...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: tema.colorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // ---- mapa + marcadores ----
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MapaWebView(
                      cidade: _cidade,
                      locais: daCidade,
                      destaque: destaque,
                      satelite: _satelite,
                      tick: _tick,
                    ),
                  ),
                  if (_carregando)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(),
                    ),
                  if (_erro != null)
                    Positioned(
                      top: 8,
                      left: 16,
                      right: 16,
                      child: Material(
                        color: tema.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            _erro!,
                            style: TextStyle(color: tema.colorScheme.onErrorContainer),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    right: 12,
                    bottom: 84,
                    child: Column(
                      children: [
                        _BotaoRedondo(
                          icone: Icons.my_location,
                          dica: 'Centralizar',
                          onPressed: () => setState(() => _tick++),
                        ),
                        const SizedBox(height: 10),
                        _BotaoRedondo(
                          icone: Icons.layers_outlined,
                          dica: _satelite ? 'Ver mapa de ruas' : 'Ver satélite',
                          onPressed: () => setState(() => _satelite = !_satelite),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: FilledButton.icon(
                      onPressed: _abrirResultados,
                      icon: const Icon(Icons.list),
                      label: Text('Ver resultados · ${daCidade.length} locais'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BarraNavegacao(atual: 0),
    );
  }
}

class _BotaoRedondo extends StatelessWidget {
  final IconData icone;
  final String dica;
  final VoidCallback onPressed;

  const _BotaoRedondo({
    required this.icone,
    required this.dica,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: dica,
        icon: Icon(icone, color: Colors.black87),
        onPressed: onPressed,
      ),
    );
  }
}
