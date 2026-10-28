import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/mensagens.dart';

/// Garante que há um administrador autenticado antes de uma operação protegida
/// (cadastrar, editar, excluir). Se não houver, abre o login em um Bottom Sheet.
Future<bool> garantirLogin(BuildContext context) async {
  if (authService.logado) return true;

  final ok = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const LoginSheet(
      motivo: 'Entre como administrador para cadastrar, editar ou excluir locais.',
    ),
  );

  if (ok == true && context.mounted) {
    mostrarMensagem(context, 'Login realizado com sucesso!');
  }
  return ok == true;
}

/// Aba "Perfil": mostra o login (se deslogado) ou os dados do usuário e o botão Sair.
Future<void> mostrarPerfil(BuildContext context) async {
  if (!authService.logado) {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const LoginSheet(
        motivo: 'Entre para liberar as operações administrativas.',
      ),
    );
    if (ok == true && context.mounted) {
      mostrarMensagem(context, 'Login realizado com sucesso!');
    }
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 32)),
              const SizedBox(height: 12),
              Text(
                authService.atual?.email ?? 'Administrador',
                style: Theme.of(ctx).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              const Text('Administrador'),
              const SizedBox(height: 20),
              FilledButton.tonalIcon(
                icon: const Icon(Icons.logout),
                label: const Text('Sair'),
                onPressed: () async {
                  await authService.sair();
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) {
                    mostrarMensagem(context, 'Você saiu da conta.');
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}

class LoginSheet extends StatefulWidget {
  final String motivo;
  const LoginSheet({super.key, required this.motivo});

  @override
  State<LoginSheet> createState() => _LoginSheetState();
}

class _LoginSheetState extends State<LoginSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  bool _entrando = false;
  bool _ocultar = true;
  String? _erro;

  @override
  void dispose() {
    _email.dispose();
    _senha.dispose();
    super.dispose();
  }

  String _traduzir(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'user-disabled':
        return 'Usuário desativado.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-mail ou senha incorretos.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      case 'operation-not-allowed':
        return 'Login por e-mail/senha não está habilitado no Firebase Console.';
      default:
        return 'Erro ao entrar (${e.code}).';
    }
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _entrando = true;
      _erro = null;
    });
    try {
      await authService.entrar(_email.text, _senha.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _entrando = false;
        _erro = _traduzir(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _entrando = false;
        _erro = 'Erro ao entrar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Entrar', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text(widget.motivo),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(
                  labelText: 'E-mail',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Informe um e-mail válido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _senha,
                obscureText: _ocultar,
                decoration: InputDecoration(
                  labelText: 'Senha',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_ocultar ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _ocultar = !_ocultar),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Informe a senha' : null,
                onFieldSubmitted: (_) => _entrar(),
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
                          _entrando ? null : () => Navigator.of(context).pop(false),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _entrando ? null : _entrar,
                      child: _entrando
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Entrar'),
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
