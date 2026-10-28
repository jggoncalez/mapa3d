import 'package:firebase_auth/firebase_auth.dart';

/// Autenticação (extensão): login por e-mail e senha.
/// Usuários autenticados são tratados como administradores.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get atual => _auth.currentUser;

  bool get logado => _auth.currentUser != null;

  Stream<User?> get usuario => _auth.authStateChanges();

  Future<void> entrar(String email, String senha) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: senha,
    );
  }

  Future<void> sair() async {
    await _auth.signOut();
  }
}

/// Instância única usada pelo app (criada somente no primeiro uso).
final AuthService authService = AuthService();
