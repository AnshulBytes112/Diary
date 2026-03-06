import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_paths.dart';

class AuthRepo {
  AuthRepo({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signUpWithEmail({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user != null) {
      await user.updateDisplayName(fullName);
      await _firestore.doc(FirestorePaths.userDoc(user.uid)).set(
        {
          'uid': user.uid,
          'email': user.email,
          'displayName': fullName,
          'createdAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    return cred;
  }

  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = cred.user;
    if (user != null) {
      await _firestore.doc(FirestorePaths.userDoc(user.uid)).set(
        {
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'lastLoginAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }
    return cred;
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }
}

