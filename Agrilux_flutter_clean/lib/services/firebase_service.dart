// lib/services/firebase_service.dart
// Equivalente a src/lib/firebase.js

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// En Flutter, Firebase se inicializa en main.dart con:
// await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
// El archivo google-services.json (Android) o GoogleService-Info.plist (iOS)
// reemplaza al firebaseConfig de JS.

class FirebaseService {
  // Equivalente a: export const db = getFirestore(app)
  static FirebaseFirestore get db => FirebaseFirestore.instance;

  // Equivalente a: export const storage = getStorage(app)
  static FirebaseStorage get storage => FirebaseStorage.instance;
}
