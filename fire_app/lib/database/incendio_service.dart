import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/incendio_model.dart';

class IncendioService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Coleção de incêndios no Firestore
  static const String collection = 'incendios';

  /// Salvar novo incêndio
  Future<String> salvarIncendio(IncendioModel incendio) async {
    try {
      final usuarioId = _auth.currentUser?.uid;
      final docRef = await _firestore.collection(collection).add(
        {
          ...incendio.toMap(),
          'criadoPor': usuarioId,
          'atualizado': FieldValue.serverTimestamp(),
        },
      );
      return docRef.id;
    } catch (e) {
      throw Exception('Erro ao salvar incêndio: $e');
    }
  }

  /// Listar todos os incêndios
  Future<List<IncendioModel>> listarIncendios() async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .orderBy('criadoEm', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => IncendioModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar incêndios: $e');
    }
  }

  /// Listar incêndios em tempo real (stream)
  Stream<List<IncendioModel>> streamIncendios() {
    return _firestore
        .collection(collection)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IncendioModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Obter incêndio por ID
  Future<IncendioModel?> obterIncendio(String id) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      if (!doc.exists) return null;
      return IncendioModel.fromMap(doc.id, doc.data()!);
    } catch (e) {
      throw Exception('Erro ao obter incêndio: $e');
    }
  }

  /// Atualizar incêndio
  Future<void> atualizarIncendio(String id, IncendioModel incendio) async {
    try {
      await _firestore.collection(collection).doc(id).update(
        {
          ...incendio.toMap(),
          'atualizado': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      throw Exception('Erro ao atualizar incêndio: $e');
    }
  }

  /// Deletar incêndio
  Future<void> deletarIncendio(String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      throw Exception('Erro ao deletar incêndio: $e');
    }
  }

  /// Listar incêndios do usuário atual
  Future<List<IncendioModel>> listarMeusIncendios() async {
    try {
      final usuarioId = _auth.currentUser?.uid;
      if (usuarioId == null) {
        throw Exception('Usuário não autenticado');
      }
      final snapshot = await _firestore
          .collection(collection)
          .where('criadoPor', isEqualTo: usuarioId)
          .orderBy('criadoEm', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => IncendioModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar meus incêndios: $e');
    }
  }

  /// Stream de incêndios do usuário atual
  Stream<List<IncendioModel>> streamMeusIncendios() {
    final usuarioId = _auth.currentUser?.uid;
    if (usuarioId == null) {
      return Stream.error('Usuário não autenticado');
    }
    return _firestore
        .collection(collection)
        .where('criadoPor', isEqualTo: usuarioId)
        .orderBy('criadoEm', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => IncendioModel.fromMap(doc.id, doc.data()))
            .toList());
  }
}
