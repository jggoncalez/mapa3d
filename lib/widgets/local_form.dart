import 'package:flutter/material.dart';

import '../models/local.dart';
import '../services/local_service.dart';
import '../utils/constantes.dart';
import '../utils/formatadores.dart';

/// Abre o formulário de cadastro (local == null) ou de edição (local preenchido)
/// em um Bottom Sheet. Devolve `true` se o registro foi salvo no Firestore.
Future<bool?> mostrarFormularioLocal(
  BuildContext context, {
  Local? local,
  String? cidadePadrao,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => LocalForm(local: local, cidadePadrao: cidadePadrao),
  );
}

class LocalForm extends StatefulWidget {
  final Local? local;
  final String? cidadePadrao;

  const LocalForm({super.key, this.local, this.cidadePadrao});

  @override
  State<LocalForm> createState() => _LocalFormState();
}

class _LocalFormState extends State<LocalForm> {
  final _formKey = GlobalKey<FormState>();
  final LocalService _service = LocalService();

  late final TextEditingController _nome =
      TextEditingController(text: widget.local?.nome ?? '');
  late final TextEditingController _horario =
      TextEditingController(text: widget.local?.horario ?? '');
  late final TextEditingController _avaliacao = TextEditingController(
      text: widget.local == null ? '' : widget.local!.avaliacao.toString());
  late final TextEditingController _distancia = TextEditingController(
      text: widget.local == null ? '' : widget.local!.distancia.toString());
  late final TextEditingController _descricao =
      TextEditingController(text: widget.local?.descricao ?? '');
  late final TextEditingController _latitude = TextEditingController(
      text: widget.local?.latitude?.toString() ?? '');
  late final TextEditingController _longitude = TextEditingController(
      text: widget.local?.longitude?.toString() ?? '');

  late String _categoria = widget.local?.categoria ?? kCategorias.first;
  late String _cidade =
      widget.local?.cidade ?? widget.cidadePadrao ?? kCidades.first;

  bool _salvando = false;
  String? _erro;

  bool get _editando => widget.local != null;

  @override
  void dispose() {
    _nome.dispose();
    _horario.dispose();
    _avaliacao.dispose();
    _distancia.dispose();
    _descricao.dispose();
    _latitude.dispose();
    _longitude.dispose();
    super.dispose();
  }

  double? _numero(String texto) =>
      double.tryParse(texto.trim().replaceAll(',', '.'));

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    final local = Local(
      id: widget.local?.id ?? '',
      nome: _nome.text.trim(),
      categoria: _categoria,
      cidade: _cidade,
      avaliacao: _numero(_avaliacao.text) ?? 0,
      distancia: _numero(_distancia.text) ?? 0,
      horario: _horario.text.trim(),
      descricao: _descricao.text.trim(),
      favorito: widget.local?.favorito ?? false,
      latitude: _numero(_latitude.text),
      longitude: _numero(_longitude.text),
    );

    try {
      if (_editando) {
        await _service.atualizar(local);
      } else {
        await _service.adicionar(local);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = 'Erro ao salvar: ${mensagemErro(e)}';
      });
    }
  }

  InputDecoration _decoracao(String rotulo, {String? dica}) => InputDecoration(
        labelText: rotulo,
        hintText: dica,
        border: const OutlineInputBorder(),
      );

  @override
  Widget build(BuildContext context) {
    // Garante que valores já gravados no banco (mesmo fora da lista) apareçam.
    final categorias = [
      ...kCategorias,
      if (!kCategorias.contains(_categoria)) _categoria,
    ];
    final cidades = [
      ...kCidades,
      if (!kCidades.contains(_cidade)) _cidade,
    ];

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _editando ? 'Editar local' : 'Cadastrar local',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nome,
                textCapitalization: TextCapitalization.words,
                decoration: _decoracao('Nome'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _categoria,
                decoration: _decoracao('Categoria'),
                items: categorias
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _categoria = v ?? _categoria),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _cidade,
                decoration: _decoracao('Cidade'),
                items: cidades
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _cidade = v ?? _cidade),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _horario,
                decoration: _decoracao('Horário', dica: '06:00 - 22:00'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Informe o horário' : null,
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _avaliacao,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _decoracao('Avaliação (0 a 5)'),
                      validator: (v) {
                        final n = _numero(v ?? '');
                        if (n == null || n < 0 || n > 5) return 'De 0 a 5';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _distancia,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: _decoracao('Distância (km)'),
                      validator: (v) {
                        final n = _numero(v ?? '');
                        if (n == null || n < 0) return 'Informe em km';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descricao,
                maxLines: 3,
                decoration: _decoracao('Descrição'),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitude,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: _decoracao('Latitude (opcional)'),
                      validator: (v) => (v != null &&
                              v.trim().isNotEmpty &&
                              _numero(v) == null)
                          ? 'Número inválido'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _longitude,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true, signed: true),
                      decoration: _decoracao('Longitude (opcional)'),
                      validator: (v) => (v != null &&
                              v.trim().isNotEmpty &&
                              _numero(v) == null)
                          ? 'Número inválido'
                          : null,
                    ),
                  ),
                ],
              ),
              if (_erro != null) ...[
                const SizedBox(height: 12),
                Text(
                  _erro!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _salvando ? null : () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _salvando ? null : _salvar,
                      child: _salvando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(_editando ? 'Salvar alterações' : 'Cadastrar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
