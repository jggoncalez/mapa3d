import 'package:flutter/material.dart';

import '../dialogs/login_sheet.dart';
import '../screens/resultados_screen.dart';
import '../utils/constantes.dart';

/// Barra inferior do wireframe: Mapa, Favoritos e Perfil.
///
/// - Mapa: volta para a tela principal.
/// - Favoritos: abre a tela de resultados já filtrada por favoritos
///   (não cria uma quarta tela principal).
/// - Perfil: abre o login/logout em um Bottom Sheet.
class BarraNavegacao extends StatelessWidget {
  /// 0 = Mapa, 1 = Favoritos.
  final int atual;

  const BarraNavegacao({super.key, this.atual = 0});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: atual,
      onDestinationSelected: (i) {
        switch (i) {
          case 0:
            Navigator.of(context).popUntil((rota) => rota.isFirst);
            break;
          case 1:
            if (atual == 1) return;
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ResultadosScreen(
                  cidade: kTodas,
                  pesquisa: '',
                  somenteFavoritos: true,
                ),
              ),
            );
            break;
          case 2:
            mostrarPerfil(context);
            break;
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite),
          label: 'Favoritos',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
