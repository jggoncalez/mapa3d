/// Formata distância em km no padrão brasileiro: 1,2 km.
String formatarKm(double km) => '${km.toStringAsFixed(1).replaceAll('.', ',')} km';

/// Formata a nota no padrão brasileiro: 4,8.
String formatarNota(double nota) => nota.toStringAsFixed(1).replaceAll('.', ',');

/// Converte "06:00 - 22:00" em "Aberto · 06:00 - 22:00" (ou "Fechado · ...").
/// Se o texto não tiver o formato esperado, devolve o próprio texto.
String statusHorario(String horario, {DateTime? agora}) {
  final m = RegExp(r'(\d{1,2}):(\d{2})\s*[-–]\s*(\d{1,2}):(\d{2})').firstMatch(horario);
  if (m == null) return horario.isEmpty ? 'Horário não informado' : horario;

  final abre = int.parse(m.group(1)!) * 60 + int.parse(m.group(2)!);
  final fecha = int.parse(m.group(3)!) * 60 + int.parse(m.group(4)!);
  final t = agora ?? DateTime.now();
  final atual = t.hour * 60 + t.minute;

  final aberto = abre <= fecha
      ? (atual >= abre && atual < fecha)
      : (atual >= abre || atual < fecha); // passa da meia-noite
  return '${aberto ? 'Aberto' : 'Fechado'} · $horario';
}

/// Converte um erro técnico em uma mensagem curta para o usuário.
String mensagemErro(Object erro) {
  final s = erro.toString();
  if (s.contains('permission-denied')) {
    return 'sem permissão (entre como administrador).';
  }
  if (s.contains('TimeoutException')) {
    return 'sem resposta do servidor. Verifique a conexão.';
  }
  if (s.contains('unavailable') || s.contains('network')) {
    return 'sem conexão com o servidor.';
  }
  return s.replaceFirst('Exception: ', '');
}
