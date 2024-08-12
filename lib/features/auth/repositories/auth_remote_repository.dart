import 'package:aparna_education/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthRemoteRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<void> signUp(
      {required String firstName,
      required String lastName,
      required String email,
      required String password,
      required String cpassword}) async {
    try {
      if (password != cpassword) {
        throw Exception('Password and Confirm Password do not match');
      }
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      UserModel user = UserModel(
        uid: userCredential.user!.uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
      );
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      print(e);
    }
  }
}
