
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> registerUser(UserModel user) async {
    try {
      UserCredential userResponse = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
          password: user.password.toString(), email: user.email.toString());

      user.uid = userResponse.user!.uid;

      // Save user data to Firestore
      await _firestore.collection('user').doc(user.uid).set(user.toMap());

      // Initialize user presence
      await _firestore.collection('user_status').doc(user.uid).set({
        'online': false,
        'lastSeen': Timestamp.now(),
      });

      return "";
    } on FirebaseAuthException catch (e) {
      print('Firebase Auth Exception: ${e.message}');
      return e.message;
    } catch (e) {
      print('Error: $e');
      return 'Registration failed: $e';
    }
  }

  Future<void> logout() async {
    SharedPreferences _pref = await SharedPreferences.getInstance();
    _pref.clear();
    await FirebaseAuth.instance.signOut();
    // Update user status to offline
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('user_status').doc(uid).update({
        'online': false,
        'lastSeen': Timestamp.now(),
      });
    }
  }

  Future<void> updateUserStatus(bool isOnline) async {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      await _firestore.collection('user_status').doc(uid).update({
        'online': isOnline,
        'lastSeen': Timestamp.now(),
      });
    }
  }

  Future<bool> isLoggedin() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? _token = pref.getString('token');
    return _token != null;
  }
}
