// Opções do Firebase para o projeto "projetomapa-e9a60" (plataforma Android).
//
// Montado a partir do google-services.json baixado do Firebase Console, com os
// mesmos campos que o FlutterFire CLI grava neste arquivo. Se você rodar
// `flutterfire configure`, ele substitui este arquivo por um equivalente
// (e pode incluir outras plataformas). Não é necessário editar os valores.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'Plataforma Web não configurada. Rode "flutterfire configure" e '
        'selecione também a Web, ou execute o app no Android.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Esta plataforma não foi configurada. Execute o app no Android '
          'ou rode "flutterfire configure".',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDjFMiLAODfVzz06atIaCXV_1CNUsDKgKc',
    appId: '1:294326746455:android:f5bfc15ee427f89fee1212',
    messagingSenderId: '294326746455',
    projectId: 'projetomapa-e9a60',
    storageBucket: 'projetomapa-e9a60.firebasestorage.app',
  );
}
