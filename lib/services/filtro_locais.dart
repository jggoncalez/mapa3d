import '../models/local.dart';
import '../utils/constantes.dart';

/// Filtra os locais em memória (pesquisa por nome/categoria, cidade e categoria).
///
/// `cidade == 'Todas'` e `categoria == 'Todos'` desativam o respectivo filtro.
/// `somenteFavoritos` mostra apenas os locais marcados como favorito.
List<Local> filtrarLocais(
  List<Local> locais,
  String texto,
  String cidade,
  String categoria, {
  bool somenteFavoritos = false,
}) {
  final termo = texto.trim().toLowerCase();

  return locais.where((local) {
    final correspondeCidade = cidade == kTodas || local.cidade == cidade;

    final correspondeCategoria =
        categoria == kTodos || local.categoria == categoria;

    final correspondeTexto = local.nome.toLowerCase().contains(termo) ||
        local.categoria.toLowerCase().contains(termo);

    final correspondeFavorito = !somenteFavoritos || local.favorito;

    return correspondeCidade &&
        correspondeCategoria &&
        correspondeTexto &&
        correspondeFavorito;
  }).toList();
}

/// Ordena do mais próximo para o mais distante (sem alterar a lista original).
List<Local> ordenarPorDistancia(List<Local> locais) {
  final copia = [...locais];
  copia.sort((a, b) => a.distancia.compareTo(b.distancia));
  return copia;
}
