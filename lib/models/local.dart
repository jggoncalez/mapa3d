/// Modelo de um estabelecimento (documento da coleção `locais`).
class Local {
  final String id;
  final String nome;
  final String categoria;
  final String cidade;
  final double avaliacao;
  final double distancia;
  final String horario;
  final String descricao;
  final bool favorito;

  /// Extensão (mapa real): coordenadas opcionais do local.
  final double? latitude;
  final double? longitude;

  Local({
    required this.id,
    required this.nome,
    required this.categoria,
    required this.cidade,
    required this.avaliacao,
    required this.distancia,
    required this.horario,
    required this.descricao,
    required this.favorito,
    this.latitude,
    this.longitude,
  });

  factory Local.fromMap(String id, Map<String, dynamic> data) {
    return Local(
      id: id,
      nome: data['nome'] ?? '',
      categoria: data['categoria'] ?? '',
      cidade: data['cidade'] ?? '',
      avaliacao: (data['avaliacao'] ?? 0).toDouble(),
      distancia: (data['distancia'] ?? 0).toDouble(),
      horario: data['horario'] ?? '',
      descricao: data['descricao'] ?? '',
      favorito: data['favorito'] ?? false,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'categoria': categoria,
      'cidade': cidade,
      'avaliacao': avaliacao,
      'distancia': distancia,
      'horario': horario,
      'descricao': descricao,
      'favorito': favorito,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
