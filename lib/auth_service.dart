import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initializeAuth() async {
    try {
      await _auth.setPersistence(Persistence.LOCAL); // Ensures session is saved
    } catch (e) {
      print("Error setting persistence: $e");
    }
  }

  Future<User?> signIn(String email, String password) async {
    try {
      await initializeAuth(); // Ensure persistence before login
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Error signing in: $e");
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
