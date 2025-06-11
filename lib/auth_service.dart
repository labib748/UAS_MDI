// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign up
  Future<User?> SignUpWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Lebih spesifik dalam menangani error Firebase Auth
      print('Firebase Auth Error (Sign Up): ${e.code} - ${e.message}');
      // Anda bisa melemparkan error ini kembali atau mengembalikan null
      return null;
    } catch (e) {
      print('General Error (Sign Up): $e');
      return null;
    }
  }

  // Sign in
  Future<User?> SignInWithEmailPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword( // <-- PERBAIKAN UTAMA DI SINI!
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // Lebih spesifik dalam menangani error Firebase Auth
      print('Firebase Auth Error (Sign In): ${e.code} - ${e.message}');
      // Anda bisa melemparkan error ini kembali atau mengembalikan null
      return null;
    } catch (e) {
      print('General Error (Sign In): $e');
      return null;
    }
  }

  // data pengguna
  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  // sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}