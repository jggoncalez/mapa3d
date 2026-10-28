import 'package:flutter/material.dart';

/// Pede confirmação antes de excluir. Devolve `true` somente se o usuário confirmar.
/// Nunca exclua direto no toque do botão: chame sempre esta função primeiro.
Future<bool> confirmarExclusao(BuildContext context, {String? nome}) async {
  final confirmou = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Excluir local?'),
        content: Text(
          nome == null
              ? 'Essa ação não poderá ser desfeita.'
              : '"$nome" será excluído. Essa ação não poderá ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );

  return confirmou == true;
}
