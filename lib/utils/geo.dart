import '../models/local.dart';
import 'constantes.dart';

/// Devolve [latitude, longitude] do local.
///
/// Se o documento não tiver coordenadas, usa o centro da cidade com um
/// pequeno deslocamento fixo (calculado a partir do id/nome), para que o
/// marcador sempre apareça no mapa.
List<double> coordenadasDe(Local local) {
  if (local.latitude != null && local.longitude != null) {
    return [local.latitude!, local.longitude!];
  }
  final centro = kCentroCidade[local.cidade] ?? kCentroCidade.values.first;
  final h = (local.id.isEmpty ? local.nome : local.id).hashCode;
  final dx = ((h % 2000) / 2000 - 0.5) * 0.04;
  final dy = (((h ~/ 2000) % 2000) / 2000 - 0.5) * 0.04;
  return [centro[0] + dy, centro[1] + dx];
}
