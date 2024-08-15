import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract interface class AuthRemoteDatasources {
  // Session? get session;
  //FirebaseAuth get firebaseAuth;
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
  Future<UserModel> signInWithGoogle();
  Future<bool> verifyEmail();
  Future<UserModel?> getCurrentUser();
  Future<FirebaseAuth> getFirebaseAuth();
}

class AuthRemoteDatasourcesImpl implements AuthRemoteDatasources {
  @override
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;
  @override
  //Session? get session => supabaseClient.auth.currentSession;
  AuthRemoteDatasourcesImpl(
      this.firebaseAuth, this.firestore, this.googleSignIn);
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

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw ServerException(message: 'User is null');
      }
      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      final user = await FirebaseAuth.instance.signInWithCredential(credential);
      if (user.user == null) {
        throw ServerException(message: 'User is null');
      } else {
        await firestore.collection('users').doc(user.user!.uid).update(
            UserModel(
                    uid: user.user!.uid,
                    email: user.user!.email ?? '',
                    firstName: user.user!.displayName ?? '',
                    lastName: user.user!.displayName ?? '')
                .toMap());
      }
      String firstName = '';
      String lastName = '';
      if (user.user!.displayName != null) {
        List<String> nameParts = user.user!.displayName!.split(' ');
        firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        lastName = nameParts.length > 1 ? nameParts[1] : '';
      }
      return UserModel(
          uid: user.user!.uid,
          email: user.user!.email ?? '',
          firstName: firstName,
          lastName: lastName);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<bool> verifyEmail() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw ServerException(message: 'User is null');
      }
      await user.sendEmailVerification();
      return true;
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<FirebaseAuth> getFirebaseAuth() {
    return Future.value(firebaseAuth);
  }
}
