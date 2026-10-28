import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/formatadores.dart';
import '../utils/mensagens.dart';
import '../widgets/barra_navegacao.dart';
import 'mapa_screen.dart';

/// Tela 3 — Detalhes de um local. Recebe o [Local] selecionado e acompanha
/// o documento no Firestore (o favorito atualiza em tempo real).
class DetalhesScreen extends StatefulWidget {
  final Local local;

  const DetalhesScreen({super.key, required this.local});

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  final LocalService _service = LocalService();
  late final Stream<Local?> _stream = _service.observarLocal(widget.local.id);

  Future<void> _favoritar(Local local) async {
    try {
      await _service.alterarFavorito(local.id, !local.favorito);
      if (!mounted) return;
      mostrarMensagem(
        context,
        !local.favorito ? 'Adicionado aos favoritos.' : 'Removido dos favoritos.',
      );
    } catch (e) {
      if (!mounted) return;
      mostrarMensagem(context, 'Erro ao alterar favorito: ${mensagemErro(e)}',
          erro: true);
    }
  }

  Future<void> _compartilhar(Local local) async {
    await Clipboard.setData(ClipboardData(
      text: '${local.nome} — ${local.categoria} em ${local.cidade} '
          '(${formatarNota(local.avaliacao)}★)',
    ));
    if (!mounted) return;
    mostrarMensagem(context, 'Dados do local copiados.');
  }

  void _verNoMapa(Local local) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapaScreen(cidadeInicial: local.cidade, destaque: local),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Local?>(
      stream: _stream,
      initialData: widget.local,
      builder: (context, snapshot) {
        final local = snapshot.data;

        if (snapshot.hasError && local == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text('Erro ao carregar o local.')),
          );
        }

        if (local == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Este local foi removido.')),
          );
        }

        return _conteudo(context, local);
      },
    );
  }

  Widget _conteudo(BuildContext context, Local local) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: local.favorito ? 'Remover dos favoritos' : 'Favoritar',
            icon: Icon(
              local.favorito ? Icons.favorite : Icons.favorite_border,
              color: local.favorito ? Colors.red : null,
            ),
            onPressed: () => _favoritar(local),
          ),
          IconButton(
            tooltip: 'Compartilhar',
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _compartilhar(local),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                // ---- imagem principal (placeholder, como no wireframe) ----
                Stack(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Icon(Icons.landscape_outlined,
                            size: 96, color: Colors.grey.shade600),
                      ),
                    ),
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('1/5',
                            style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 5; i++)
                      Container(
                        width: 6,
                        height: 6,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == 0 ? Colors.black87 : Colors.black26,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 14),

                // ---- nome, categoria, avaliação ----
                Text(local.nome,
                    style: tema.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800)),
                Text(local.categoria, style: tema.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const SizedBox(width: 4),
                    Text(formatarNota(local.avaliacao),
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const Text(' de 5'),
                  ],
                ),
                const SizedBox(height: 12),

                // ---- distância e horário ----
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text(formatarKm(local.distancia)),
                    const SizedBox(width: 20),
                    const Icon(Icons.schedule, size: 18),
                    const SizedBox(width: 4),
                    Expanded(child: Text(statusHorario(local.horario))),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_city_outlined, size: 18),
                    const SizedBox(width: 4),
                    Text(local.cidade),
                  ],
                ),
                const Divider(height: 28),

                // ---- ações rápidas ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _Acao(
                      icone: Icons.call_outlined,
                      rotulo: 'Ligar',
                      onTap: () => mostrarMensagem(
                          context, 'Telefone não cadastrado para este local.'),
                    ),
                    _Acao(
                      icone: Icons.navigation_outlined,
                      rotulo: 'Como chegar',
                      onTap: () => _verNoMapa(local),
                    ),
                    _Acao(
                      icone: Icons.event_outlined,
                      rotulo: 'Agendar',
                      onTap: () => mostrarMensagem(
                          context, 'Agendamento disponível em breve.'),
                    ),
                  ],
                ),
                const Divider(height: 28),

                // ---- sobre ----
                Text('Sobre',
                    style: tema.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                Text(local.descricao.isEmpty
                    ? 'Sem descrição cadastrada.'
                    : local.descricao),
                const Divider(height: 28),

                // ---- fotos (placeholders) ----
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Fotos',
                        style: tema.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    TextButton(
                      onPressed: () => mostrarMensagem(
                          context, 'Galeria de fotos não implementada.'),
                      child: const Text('Ver todas >'),
                    ),
                  ],
                ),
                Row(
                  children: [
                    for (var i = 0; i < 3; i++)
                      Expanded(
                        child: Container(
                          height: 72,
                          margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.image_outlined,
                              color: Colors.grey.shade600),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // ---- ver no mapa ----
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.grey.shade900,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () => _verNoMapa(local),
                icon: const Icon(Icons.place),
                label: const Text('Ver no mapa'),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BarraNavegacao(atual: 0),
    );
  }
}

class _Acao extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final VoidCallback onTap;

  const _Acao({required this.icone, required this.rotulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black26),
              ),
              child: Icon(icone),
            ),
            const SizedBox(height: 6),
            Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
