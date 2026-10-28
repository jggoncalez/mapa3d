import 'package:flutter/material.dart';

/// Mostra uma mensagem de sucesso ou de erro (SnackBar) para o usuário.
void mostrarMensagem(BuildContext context, String texto, {bool erro = false}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(texto),
        behavior: SnackBarBehavior.floating,
        backgroundColor: erro ? Theme.of(context).colorScheme.error : null,
      ),
    );
}
