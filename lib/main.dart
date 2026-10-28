import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/mapa_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String? erroFirebase;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    erroFirebase = e.toString();
  }

  runApp(
    erroFirebase == null
        ? const MinhaAplicacao()
        : AppConfiguracaoPendente(erro: erroFirebase),
  );
}

class MinhaAplicacao extends StatelessWidget {
  const MinhaAplicacao({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mapa de Locais',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const MapaScreen(),
    );
  }
}

/// Mostrada somente se o Firebase não puder ser inicializado
/// (por exemplo, antes de rodar `flutterfire configure`).
class AppConfiguracaoPendente extends StatelessWidget {
  final String erro;

  const AppConfiguracaoPendente({super.key, required this.erro});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 56),
                    const SizedBox(height: 12),
                    const Text(
                      'Firebase não configurado',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Na pasta do projeto, rode no terminal:\n\n'
                      'firebase login\n'
                      'flutterfire configure\n\n'
                      'Selecione o projeto do Firebase e a plataforma Android '
                      'e depois execute o app novamente.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      erro,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
