// auth_remote_datasources.dart

import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';

/// Abstract class defining the contract for authentication remote data sources.
abstract interface class AuthRemoteDataSources {
  FirebaseAuth get firebaseAuth;
  FirebaseFirestore get firestore;
  GoogleSignIn get googleSignIn;

  /// Registers a new user with email and password along with additional details.
  Future<UserModel> signUpWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String middleName,
    required String email,
    required String password,
  });

  /// Logs in an existing user using email and password.
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Facilitates user sign-in using Google credentials.
  Future<UserModel> signInWithGoogle();

  /// Sends a verification email to the current user.
  Future<bool> verifyEmail();

  /// Updates the email verification status in Firestore.
  Future<void> updateEmailVerification();

  /// Retrieves the currently authenticated user's details.
  Future<UserModel?> getCurrentUser();

  /// Provides access to the FirebaseAuth instance.
  Future<FirebaseAuth> getFirebaseAuth();

  /// Checks if the current user's email is verified.
  Future<bool> isUserEmailVerified();
}

/// Implementation of [AuthRemoteDataSources] using Firebase services.
class AuthRemoteDataSourcesImpl implements AuthRemoteDataSources {
  @override
  final FirebaseAuth firebaseAuth;
  
  @override
  final FirebaseFirestore firestore;
  
  @override
  final GoogleSignIn googleSignIn;

  final Logger _logger;

  /// Constructor with dependency injection for FirebaseAuth, FirebaseFirestore, GoogleSignIn, and Logger.
  AuthRemoteDataSourcesImpl(
      this.firebaseAuth, this.firestore, this.googleSignIn, this._logger);

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Attempting to log in user with email: $email');
      final response = await firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);

      final user = response.user;
      if (user == null) {
        _logger.e('User is null after login attempt.');
        throw ServerException(message: 'User is null');
      }

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        _logger.e('User data not found in Firestore for UID: ${user.uid}');
        throw ServerException(message: 'User data not found');
      }

      return UserModel.fromMap(userDoc.data()!);
    } on FirebaseAuthException catch (e) {
      _logger.e('FirebaseAuthException during login: ${e.message}');
      throw ServerException(message: e.message ?? 'Authentication failed');
    } catch (e) {
      _logger.e('Unknown error during login: $e');
      throw ServerException(message: 'Unknown error during login');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String middleName,
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Attempting to sign up user with email: $email');
      final response = await firebaseAuth.createUserWithEmailAndPassword(
          email: email, password: password);

      final user = response.user;
      if (user == null) {
        _logger.e('User is null after sign up attempt.');
        throw ServerException(message: 'User is null');
      }

      final newUser = UserModel(
        emailVerified: false,
        middleName: middleName,
        email: email,
        firstName: firstName,
        uid: user.uid,
        lastName: lastName,
      );

      await firestore.collection('users').doc(user.uid).set(newUser.toMap());
      _logger.i('User data saved to Firestore for UID: ${user.uid}');

      return newUser;
    } on FirebaseAuthException catch (e) {
      _logger.e('FirebaseAuthException during sign up: ${e.message}');
      throw ServerException(message: e.message ?? 'Sign up failed');
    } catch (e) {
      _logger.e('Unknown error during sign up: $e');
      throw ServerException(message: 'Unknown error during sign up');
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      _logger.i('Initiating Google Sign-In');
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        _logger.w('Google Sign-In aborted by user.');
        throw ServerException(message: 'Google Sign-In aborted');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await firebaseAuth.signInWithCredential(credential);
      final user = authResult.user;

      if (user == null) {
        _logger.e('User is null after Google Sign-In.');
        throw ServerException(message: 'User is null');
      }

      // Extracting names from displayName
      String firstName = '';
      String lastName = '';
      if (user.displayName != null) {
        List<String> nameParts = user.displayName!.split(' ');
        firstName = nameParts.isNotEmpty ? nameParts[0] : '';
        lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      }

      // Update Firestore with user info
      final userModel = UserModel(
        emailVerified: user.emailVerified,
        uid: user.uid,
        email: user.email ?? '',
        firstName: firstName,
        lastName: lastName,
        middleName: '',
      );

      await firestore.collection('users').doc(user.uid).set(userModel.toMap(),
          SetOptions(merge: true));
      _logger.i('User data updated in Firestore for UID: ${user.uid}');

      return userModel;
    } on FirebaseAuthException catch (e) {
      _logger.e('FirebaseAuthException during Google Sign-In: ${e.message}');
      throw ServerException(message: e.message ?? 'Google Sign-In failed');
    } catch (e) {
      _logger.e('Unknown error during Google Sign-In: $e');
      throw ServerException(message: 'Unknown error during Google Sign-In');
    }
  }

  @override
  Future<bool> verifyEmail() async {
    try {
      _logger.i('Sending email verification to user.');
      final user = firebaseAuth.currentUser;

      if (user == null) {
        _logger.e('No current user found for email verification.');
        throw ServerException(message: 'User is null');
      }

      await user.sendEmailVerification();
      _logger.i('Email verification sent to ${user.email}.');
      return true;
    } on FirebaseAuthException catch (e) {
      _logger.e('FirebaseAuthException during email verification: ${e.message}');
      throw ServerException(message: e.message ?? 'Failed to send verification email');
    } catch (e) {
      _logger.e('Unknown error during email verification: $e');
      throw ServerException(message: 'Unknown error during email verification');
    }
  }

  @override
  Future<void> updateEmailVerification() async {
    try {
      _logger.i('Updating email verification status in Firestore.');
      final user = firebaseAuth.currentUser;

      if (user == null) {
        _logger.e('No current user found for updating email verification.');
        throw ServerException(message: 'User is null');
      }

      await firestore.collection('users').doc(user.uid).update({
        'emailVerified': true,
      });
      _logger.i('Email verification status updated in Firestore for UID: ${user.uid}.');
    } on FirebaseException catch (e) {
      _logger.e('FirebaseException during updating email verification: ${e.message}');
      throw ServerException(message: e.message ?? 'Failed to update email verification');
    } catch (e) {
      _logger.e('Unknown error during updating email verification: $e');
      throw ServerException(message: 'Unknown error during updating email verification');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      _logger.i('Fetching current user.');
      final user = firebaseAuth.currentUser;

      if (user == null) {
        _logger.w('No current user found.');
        return null;
      }

      final userDoc = await firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists || userDoc.data() == null) {
        _logger.e('User data not found in Firestore for UID: ${user.uid}');
        return null;
      }

      return UserModel.fromMap(userDoc.data()!);
    } catch (e) {
      _logger.e('Error fetching current user: $e');
      throw ServerException(message: 'Error fetching current user');
    }
  }

  @override
  Future<FirebaseAuth> getFirebaseAuth() async {
    _logger.i('Retrieving FirebaseAuth instance.');
    return firebaseAuth;
  }

  @override
  Future<bool> isUserEmailVerified() async {
    try {
      _logger.i('Checking if user email is verified.');
      final user = firebaseAuth.currentUser;

      if (user == null) {
        _logger.w('No current user found for email verification check.');
        throw ServerException(message: 'User is null');
      }

      await user.reload();
      final refreshedUser = firebaseAuth.currentUser;

      final emailVerified = refreshedUser?.emailVerified ?? false;
      _logger.i('Email verified: $emailVerified');
      return emailVerified;
    } catch (e) {
      _logger.e('Error checking email verification: $e');
      throw ServerException(message: 'Error checking email verification');
    }
  }
}
