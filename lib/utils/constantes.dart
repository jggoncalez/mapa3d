/// Cidades disponíveis no seletor da tela principal.
/// Mínimo exigido pelo documento: São Paulo, Campinas e Jundiaí.
const List<String> kCidades = ['São Paulo', 'Campinas', 'Jundiaí', 'Limeira'];

/// Valor "sem filtro" para cidade (tela de resultados).
const String kTodas = 'Todas';

/// Valor "sem filtro" para categoria (tela de resultados).
const String kTodos = 'Todos';

/// Categorias usadas nos filtros e no formulário de cadastro.
const List<String> kCategorias = ['Academia', 'Restaurante', 'Hospital'];

/// Rótulos dos chips de categoria (como no wireframe: plural).
const Map<String, String> kRotuloCategoria = {
  'Academia': 'Academias',
  'Restaurante': 'Restaurantes',
  'Hospital': 'Hospitais',
};

/// Centro de cada cidade: [latitude, longitude]. Usado pelo mapa real.
const Map<String, List<double>> kCentroCidade = {
  'São Paulo': [-23.5614, -46.6559],
  'Campinas': [-22.9056, -47.0608],
  'Jundiaí': [-23.1857, -46.8978],
  'Limeira': [-22.5647, -47.4017],
};
