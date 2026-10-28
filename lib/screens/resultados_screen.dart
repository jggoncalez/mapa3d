import 'package:flutter/material.dart';

import '../dialogs/confirm_delete.dart';
import '../dialogs/login_sheet.dart';
import '../models/local.dart';
import '../services/filtro_locais.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../utils/formatadores.dart';
import '../utils/mensagens.dart';
import '../widgets/barra_navegacao.dart';
import '../widgets/local_card.dart';
import '../widgets/local_form.dart';
import 'detalhes_screen.dart';

/// Tela 2 — Resultados. Lê os locais do Firestore, filtra e permite
/// abrir detalhes, cadastrar, editar e excluir.
class ResultadosScreen extends StatefulWidget {
  final String cidade;
  final String pesquisa;
  final bool somenteFavoritos;

  const ResultadosScreen({
    super.key,
    this.cidade = kTodas,
    this.pesquisa = '',
    this.somenteFavoritos = false,
  });

  @override
  State<ResultadosScreen> createState() => _ResultadosScreenState();
}

class _ResultadosScreenState extends State<ResultadosScreen> {
  final LocalService _service = LocalService();
  late final Stream<List<Local>> _stream = _service.listarLocais();
  late final TextEditingController _busca =
      TextEditingController(text: widget.pesquisa);

  late String _cidade = widget.cidade;
  String _categoria = kTodos;
  late bool _favoritos = widget.somenteFavoritos;

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  // ---------------- ações ----------------

  Future<void> _escolherCidade() async {
    final escolhida = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final c in [kTodas, ...kCidades])
              ListTile(
                title: Text(c),
                trailing: c == _cidade ? const Icon(Icons.check) : null,
                onTap: () => Navigator.pop(ctx, c),
              ),
          ],
        ),
      ),
    );
    if (escolhida != null) setState(() => _cidade = escolhida);
  }

  void _abrirDetalhes(Local local) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetalhesScreen(local: local)),
    );
  }

  Future<void> _cadastrar() async {
    if (!await garantirLogin(context)) return;
    if (!mounted) return;
    final ok = await mostrarFormularioLocal(
      context,
      cidadePadrao: _cidade == kTodas ? null : _cidade,
    );
    if (ok == true && mounted) {
      mostrarMensagem(context, 'Local cadastrado com sucesso!');
    }
  }

  Future<void> _editar(Local local) async {
    if (!await garantirLogin(context)) return;
    if (!mounted) return;
    final ok = await mostrarFormularioLocal(context, local: local);
    if (ok == true && mounted) {
      mostrarMensagem(context, 'Local atualizado com sucesso!');
    }
  }

  Future<void> _excluir(Local local) async {
    if (!await garantirLogin(context)) return;
    if (!mounted) return;
    final confirmou = await confirmarExclusao(context, nome: local.nome);
    if (!confirmou || !mounted) return;
    try {
      await _service.excluir(local.id);
      if (mounted) mostrarMensagem(context, 'Local excluído com sucesso!');
    } catch (e) {
      if (mounted) {
        mostrarMensagem(context, 'Erro ao excluir: ${mensagemErro(e)}', erro: true);
      }
    }
  }

  Future<void> _carregarExemplos() async {
    if (!await garantirLogin(context)) return;
    if (!mounted) return;
    try {
      final n = await _service.popularExemplo();
      if (!mounted) return;
      mostrarMensagem(
        context,
        n > 0 ? '$n locais de exemplo cadastrados!' : 'A coleção já possui dados.',
      );
    } catch (e) {
      if (mounted) {
        mostrarMensagem(context, 'Erro ao cadastrar exemplos: ${mensagemErro(e)}',
            erro: true);
      }
    }
  }

  // ---------------- interface ----------------

  Widget _filtros() {
    final tema = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _busca,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Pesquisar por nome ou categoria',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _busca.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(_busca.clear),
                    ),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _escolherCidade,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(color: tema.colorScheme.outline),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_cidade)),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              for (final c in [kTodos, ...kCategorias])
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(c == kTodos ? kTodos : (kRotuloCategoria[c] ?? c)),
                    selected: _categoria == c,
                    onSelected: (_) => setState(() => _categoria = c),
                  ),
                ),
              FilterChip(
                avatar: const Icon(Icons.favorite, size: 16, color: Colors.red),
                label: const Text('Favoritos'),
                selected: _favoritos,
                onSelected: (v) => setState(() => _favoritos = v),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vazio({required bool colecaoVazia}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 48),
            const SizedBox(height: 8),
            const Text('Nenhum local encontrado.'),
            if (colecaoVazia) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _carregarExemplos,
                icon: const Icon(Icons.cloud_upload_outlined),
                label: const Text('Carregar dados de exemplo (administrador)'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _lista() {
    return StreamBuilder<List<Local>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 8),
                  const Text('Erro ao carregar os locais.'),
                  const SizedBox(height: 4),
                  Text(
                    mensagemErro(snapshot.error!),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        }

        final todos = snapshot.data ?? [];
        final filtrados = ordenarPorDistancia(
          filtrarLocais(
            todos,
            _busca.text,
            _cidade,
            _categoria,
            somenteFavoritos: _favoritos,
          ),
        );

        if (filtrados.isEmpty) {
          return _vazio(colecaoVazia: todos.isEmpty);
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 4, bottom: 88),
          itemCount: filtrados.length,
          itemBuilder: (context, index) {
            final local = filtrados[index];
            return LocalCard(
              local: local,
              onTap: () => _abrirDetalhes(local),
              onEditar: () => _editar(local),
              onExcluir: () => _excluir(local),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _filtros(),
          const SizedBox(height: 4),
          Expanded(child: _lista()),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _cadastrar,
        icon: const Icon(Icons.add),
        label: const Text('Cadastrar local'),
      ),
      bottomNavigationBar: BarraNavegacao(atual: widget.somenteFavoritos ? 1 : 0),
    );
  }
}
