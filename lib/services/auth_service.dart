import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _google = GoogleSignIn();
  final _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'name': user.displayName,
        'email': user.email,
        'photoUrl': user.photoURL,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return user;
  }

  Future<User?> signInAsGuest() async {
    final result = await _auth.signInAnonymously();
    final user = result.user;

    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set({
        'isGuest': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return user;
  }

  Future<User?> linkGuestWithGoogle() async {
    final googleUser = await _google.signIn();
    if (googleUser == null) return null;

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final currentUser = _auth.currentUser;

    try {
      // 🟢 TRY NORMAL LINK (best case)
      final result =
      await currentUser!.linkWithCredential(credential);

      await _firestore.collection('users').doc(result.user!.uid).update({
        'isGuest': false,
        'email': result.user!.email,
        'name': result.user!.displayName,
        'photoUrl': result.user!.photoURL,
      });

      return result.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        // 🔥 IMPORTANT CASE

        // 1️⃣ Sign in with Google (existing account)
        final googleResult =
        await _auth.signInWithCredential(credential);

        final googleUser = googleResult.user!;

        // 2️⃣ MIGRATE DATA from guest → google
        await _migrateGuestData(
          fromUid: currentUser!.uid,
          toUid: googleUser.uid,
        );

        // 3️⃣ Delete guest account
        await currentUser.delete();

        return googleUser;
      }

      rethrow;
    }
  }

  Future<void> _migrateGuestData({
    required String fromUid,
    required String toUid,
  }) async {
    final batch = _firestore.batch();

    // 🔹 Tasks
    final tasks = await _firestore
        .collection('users')
        .doc(fromUid)
        .collection('tasks')
        .get();

    for (var doc in tasks.docs) {
      batch.set(
        _firestore
            .collection('users')
            .doc(toUid)
            .collection('tasks')
            .doc(doc.id),
        doc.data(),
      );
    }

    // 🔹 Habits
    final habits = await _firestore
        .collection('users')
        .doc(fromUid)
        .collection('habits')
        .get();

    for (var doc in habits.docs) {
      batch.set(
        _firestore
            .collection('users')
            .doc(toUid)
            .collection('habits')
            .doc(doc.id),
        doc.data(),
      );
    }

    await batch.commit();

    // 🔹 Cleanup guest data
    await _firestore.collection('users').doc(fromUid).delete();
  }


  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }

}