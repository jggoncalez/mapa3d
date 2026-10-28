import '../models/local.dart';
import '../utils/constantes.dart';

/// Cria um local de exemplo a partir do centro da cidade + deslocamento.
Local _l(
  String nome,
  String categoria,
  String cidade,
  double nota,
  double km,
  String horario,
  String descricao,
  double dLat,
  double dLng,
) {
  final c = kCentroCidade[cidade]!;
  return Local(
    id: '',
    nome: nome,
    categoria: categoria,
    cidade: cidade,
    avaliacao: nota,
    distancia: km,
    horario: horario,
    descricao: descricao,
    favorito: false,
    latitude: c[0] + dLat,
    longitude: c[1] + dLng,
  );
}

/// 20 locais fictícios (5 por cidade) para testar o aplicativo.
/// Os estabelecimentos são inventados; servem apenas como dados de teste.
List<Local> dadosExemplo() {
  return [
    // ---------- São Paulo ----------
    _l('Academia Fitness', 'Academia', 'São Paulo', 4.8, 1.2, '06:00 - 22:00',
        'Academia completa com musculação, funcional, aulas coletivas e personal trainer. Ambiente moderno e bem equipado.', 0.004, 0.006),
    _l('Body Center', 'Academia', 'São Paulo', 4.3, 3.1, '05:30 - 23:00',
        'Equipamentos novos, piscina aquecida e aulas de ritmos.', -0.012, 0.010),
    _l('Restaurante Sabor Paulista', 'Restaurante', 'São Paulo', 4.6, 0.8, '11:00 - 23:00',
        'Culinária brasileira com pratos executivos e feijoada aos sábados.', 0.002, -0.008),
    _l('Hospital Central', 'Hospital', 'São Paulo', 4.1, 2.4, '00:00 - 23:59',
        'Atendimento de urgência 24 horas e consultas com especialistas.', -0.006, -0.014),
    _l('Cantina da Praça', 'Restaurante', 'São Paulo', 4.4, 1.9, '11:30 - 22:30',
        'Massas artesanais e pizzas no forno a lenha.', 0.010, -0.004),

    // ---------- Campinas ----------
    _l('Iron Gym', 'Academia', 'Campinas', 4.2, 5.2, '06:00 - 22:00',
        'Foco em musculação e treinamento de força, com professores em todos os horários.', 0.006, 0.008),
    _l('Academia Movimento', 'Academia', 'Campinas', 4.5, 2.2, '05:00 - 23:00',
        'Aulas de spinning, pilates e funcional, com avaliação física gratuita.', -0.009, 0.005),
    _l('Restaurante Bom Prato Campineiro', 'Restaurante', 'Campinas', 4.7, 1.1, '11:00 - 15:00',
        'Almoço self-service com opções vegetarianas e sobremesas caseiras.', 0.003, -0.011),
    _l('Hospital Santa Clara', 'Hospital', 'Campinas', 4.0, 3.4, '00:00 - 23:59',
        'Pronto atendimento, maternidade e centro de diagnóstico por imagem.', -0.014, -0.006),
    _l('Pizzaria do Cambuí', 'Restaurante', 'Campinas', 4.5, 1.6, '18:00 - 23:30',
        'Pizzas tradicionais e especiais, com ambiente familiar.', 0.011, 0.002),

    // ---------- Jundiaí ----------
    _l('Academia Serra do Japi', 'Academia', 'Jundiaí', 4.4, 1.4, '06:00 - 21:00',
        'Treinos funcionais ao ar livre e salão de musculação climatizado.', 0.005, 0.007),
    _l('Gym Jundiaí', 'Academia', 'Jundiaí', 4.1, 2.8, '06:00 - 22:00',
        'Academia de bairro com preços acessíveis e aulas de dança.', -0.008, 0.012),
    _l('Restaurante Uva e Vinho', 'Restaurante', 'Jundiaí', 4.8, 0.9, '11:30 - 23:00',
        'Culinária italiana e carta de vinhos da região.', 0.001, -0.009),
    _l('Pronto Atendimento Central', 'Hospital', 'Jundiaí', 3.9, 2.0, '00:00 - 23:59',
        'Atendimento de urgência e emergência 24 horas.', -0.011, -0.005),
    _l('Cantina Nonna Rosa', 'Restaurante', 'Jundiaí', 4.6, 1.7, '12:00 - 22:00',
        'Receitas de família, massas frescas e tiramisù.', 0.009, -0.003),

    // ---------- Limeira ----------
    _l('Academia Laranja Fit', 'Academia', 'Limeira', 4.5, 1.0, '06:00 - 22:00',
        'Musculação, aulas coletivas e espaço kids.', 0.004, 0.005),
    _l('Academia Força Total', 'Academia', 'Limeira', 4.2, 2.6, '05:30 - 22:30',
        'Treino de força, crossfit e acompanhamento nutricional.', -0.007, 0.009),
    _l('Restaurante Sabor da Laranja', 'Restaurante', 'Limeira', 4.6, 0.7, '11:00 - 15:00',
        'Almoço caseiro com buffet variado e sobremesas.', 0.002, -0.006),
    _l('Pronto Socorro Municipal', 'Hospital', 'Limeira', 4.0, 2.3, '00:00 - 23:59',
        'Atendimento de urgência 24 horas.', -0.010, -0.010),
    _l('Churrascaria Praça Toledo', 'Restaurante', 'Limeira', 4.4, 1.5, '11:30 - 23:00',
        'Rodízio de carnes e buffet de saladas.', 0.008, -0.002),
  ];
}
