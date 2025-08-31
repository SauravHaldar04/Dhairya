// auth_remote_datasources.dart

import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/features/auth/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Abstract class defining the contract for authentication remote data sources.
abstract interface class AuthRemoteDataSources {
  SupabaseClient get supabaseClient;

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

  /// Sends a verification email to the current user.
  Future<bool> verifyEmail();

  /// Updates the email verification status in Firestore.
  Future<void> updateEmailVerification();

  /// Retrieves the currently authenticated user's details.
  Future<UserModel?> getCurrentUser();

  /// Checks if the current user's email is verified.
  Future<bool> isUserEmailVerified();
}

/// Implementation of [AuthRemoteDataSources] using Supabase services.
class AuthRemoteDataSourcesImpl implements AuthRemoteDataSources {
  @override
  final SupabaseClient supabaseClient;

  /// Constructor with dependency injection for SupabaseClient.
  AuthRemoteDataSourcesImpl(this.supabaseClient);

  @override
  Future<UserModel> loginWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final response = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) throw Exception('Login failed');
    final userData = await supabaseClient.from('users').select().eq('uid', response.user!.id).single();
    return UserModel(
      uid: response.user!.id,
      email: userData['email'],
      firstName: userData['first_name'],
      middleName: userData['middle_name'],
      lastName: userData['last_name'],
      emailVerified: userData['email_verified'],
      userType: Usertype.none,
    );
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String firstName,
    required String lastName,
    required String middleName,
    required String email,
    required String password,
  }) async {
    final response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: {
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
      },
    );
    if (response.user == null) throw Exception('Sign up failed');
    await supabaseClient.from('users').insert({
      'uid': response.user!.id,
      'email': email,
      'first_name': firstName,
      'middle_name': middleName,
      'last_name': lastName,
      'email_verified': false,
      'user_type': toStringValue(Usertype.none),
    });
    return UserModel(
      uid: response.user!.id,
      email: email,
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      emailVerified: false,
      userType: Usertype.none,
    );
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return null;
    final userData = await supabaseClient.from('users').select().eq('uid', user.id).single();
    return UserModel(
      uid: user.id,
      email: userData['email'],
      firstName: userData['first_name'],
      middleName: userData['middle_name'],
      lastName: userData['last_name'],
      emailVerified: userData['email_verified'],
      userType: getEnumFromString(userData['user_type']),
    );
  }

  @override
  Future<bool> verifyEmail() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return false;
    
    try {
      await supabaseClient.auth.resend(
        type: OtpType.signup,
        email: user.email,
      );
      return true;
    } catch (e) {
      print('Error sending verification email: $e');
      return false;
    }
  }

  @override
  Future<void> updateEmailVerification() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return;
    
    // Update the database to mark email as verified
    await supabaseClient.from('users').update({'email_verified': true}).eq('uid', user.id);
    
    // Log the update for debugging
    print('Updated email_verified to true for user: ${user.id}');
  }

  @override
  Future<bool> isUserEmailVerified() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return false;
    
    try {
      // Check Supabase Auth email verification status directly
      final isAuthVerified = user.emailConfirmedAt != null;
      
      if (isAuthVerified) {
        // If Supabase Auth says email is verified, update our database
        await supabaseClient.from('users').update({'email_verified': true}).eq('uid', user.id);
        return true;
      }
      
      // Fallback: check our database field
      final userData = await supabaseClient.from('users').select('email_verified').eq('uid', user.id).single();
      return userData['email_verified'] ?? false;
    } catch (e) {
      print('Error checking email verification: $e');
      // If there's an error, fallback to database check
      try {
        final userData = await supabaseClient.from('users').select('email_verified').eq('uid', user.id).single();
        return userData['email_verified'] ?? false;
      } catch (dbError) {
        print('Error checking database: $dbError');
        return false;
      }
    }
  }
}
