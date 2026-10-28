import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/local.dart';
import 'dados_exemplo.dart';

/// Única classe que conversa com o Cloud Firestore.
/// As telas nunca chamam o banco diretamente.
class LocalService {
  final CollectionReference locais =
      FirebaseFirestore.instance.collection('locais');

  /// Tempo máximo de espera por uma gravação (evita travar sem internet).
  static const Duration _limite = Duration(seconds: 15);

  /// READ — lista em tempo real todos os locais.
  Stream<List<Local>> listarLocais() {
    return locais.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Local.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  /// READ — acompanha um único documento (usado na tela de detalhes).
  /// Emite `null` se o documento for excluído.
  Stream<Local?> observarLocal(String id) {
    return locais.doc(id).snapshots().map<Local?>((doc) {
      final data = doc.data();
      if (!doc.exists || data == null) return null;
      return Local.fromMap(doc.id, data as Map<String, dynamic>);
    });
  }

  /// CREATE — cadastra um novo local (o id é gerado pelo Firestore).
  Future<void> adicionar(Local local) async {
    await locais.add(local.toMap()).timeout(_limite);
  }

  /// UPDATE — altera os dados de um local existente.
  Future<void> atualizar(Local local) async {
    await locais.doc(local.id).update(local.toMap()).timeout(_limite);
  }

  /// DELETE — exclui um local (a confirmação é feita na tela).
  Future<void> excluir(String id) async {
    await locais.doc(id).delete().timeout(_limite);
  }

  /// UPDATE — altera somente o campo `favorito`.
  Future<void> alterarFavorito(
    String id,
    bool favorito,
  ) async {
    await locais.doc(id).update({
      'favorito': favorito,
    }).timeout(_limite);
  }

  /// Cadastra os locais de exemplo, somente se a coleção estiver vazia.
  /// Devolve quantos documentos foram criados.
  Future<int> popularExemplo() async {
    final existentes = await locais.limit(1).get().timeout(_limite);
    if (existentes.docs.isNotEmpty) return 0;

    final batch = FirebaseFirestore.instance.batch();
    final dados = dadosExemplo();
    for (final local in dados) {
      batch.set(locais.doc(), local.toMap());
    }
    await batch.commit().timeout(_limite);
    return dados.length;
  }
}
