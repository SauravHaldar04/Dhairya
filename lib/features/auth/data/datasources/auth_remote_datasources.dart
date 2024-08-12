import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';


abstract interface class AuthRemoteDatasources {
  // Session? get session;
  Future<UserModel> signInWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  });
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDatasourcesImpl implements AuthRemoteDatasources {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  @override
  //Session? get session => supabaseClient.auth.currentSession;
  AuthRemoteDatasourcesImpl(this.firebaseAuth, this.firestore);
  @override
  Future<UserModel> loginWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final response = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      if (response.user == null) {
        throw ServerException(message: 'User is null');
      }
      return await firestore
          .collection('users')
          .doc(response.user!.uid)
          .get()
          .then((value) => UserModel.fromMap(value.data()!));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);
      final user = UserModel(
          email: email,
          firstName: firstName,
          uid: response.user!.uid,
          lastName: lastName);
      await firestore
          .collection('users')
          .doc(response.user!.uid)
          .set(user.toMap());
      if (response.user == null) {
        throw ServerException(message: 'User is null');
      }
      return user;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return null;
      }
      return await firestore
          .collection('users')
          .doc(user.uid)
          .get()
          .then((value) => UserModel.fromMap(value.data()!));
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
