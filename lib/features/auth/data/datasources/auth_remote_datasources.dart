// auth_remote_datasources.dart

import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/features/auth/data/models/user_model.dart';
import 'package:aparna_education/core/secrets/secrets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

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

  /// Signs in a user using Google OAuth.
  Future<UserModel> signInWithGoogle();

  /// Sends a verification email to the current user.
  Future<bool> verifyEmail();

  /// Updates the email verification status in Firestore.
  Future<void> updateEmailVerification();

  /// Retrieves the currently authenticated user's details.
  Future<UserModel?> getCurrentUser();

  /// Checks if the current user's email is verified.
  Future<bool> isUserEmailVerified();
  
  /// Logs out the current user.
  Future<void> logout();
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
  Future<UserModel> signInWithGoogle() async {
    try {
      // If already signed in, just return the current user model
      final already = supabaseClient.auth.currentUser;
      if (already != null) {
        final data = await supabaseClient.from('users').select().eq('uid', already.id).maybeSingle();
        if (data != null) {
          return UserModel(
            uid: already.id,
            email: data['email'],
            firstName: data['first_name'],
            middleName: data['middle_name'],
            lastName: data['last_name'],
            emailVerified: data['email_verified'],
            userType: getEnumFromString(data['user_type']),
          );
        }
      }

      final completer = Completer<UserModel>();
      late final StreamSubscription authSub;
      authSub = supabaseClient.auth.onAuthStateChange.listen((event) async {
        final session = event.session;
        if ((event.event == AuthChangeEvent.signedIn || event.event == AuthChangeEvent.userUpdated) && session?.user != null && !completer.isCompleted) {
          try {
            final user = session!.user;
            // Ensure user row exists
            final existing = await supabaseClient.from('users').select().eq('uid', user.id).maybeSingle();
            if (existing == null) {
              final displayName = user.userMetadata?['full_name'] as String? ?? '';
              final parts = displayName.split(' ');
              final first = parts.isNotEmpty ? parts.first : '';
              final last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
              await supabaseClient.from('users').insert({
                'uid': user.id,
                'email': user.email ?? '',
                'first_name': first,
                'middle_name': '',
                'last_name': last,
                'email_verified': user.emailConfirmedAt != null,
                'user_type': toStringValue(Usertype.none),
              });
              completer.complete(UserModel(
                uid: user.id,
                email: user.email ?? '',
                firstName: first,
                middleName: '',
                lastName: last,
                emailVerified: user.emailConfirmedAt != null,
                userType: Usertype.none,
              ));
            } else {
              completer.complete(UserModel(
                uid: user.id,
                email: existing['email'],
                firstName: existing['first_name'],
                middleName: existing['middle_name'],
                lastName: existing['last_name'],
                emailVerified: existing['email_verified'],
                userType: getEnumFromString(existing['user_type']),
              ));
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.completeError(Exception('Post sign-in handling failed: $e'));
            }
          } finally {
            authSub.cancel();
          }
        }
      });

      // Trigger Supabase OAuth flow
      try {
        const baseUrl = Secrets.supabaseUrl; // from secrets
        final expectedRedirect = '$baseUrl/auth/v1/callback';
        // Debug print to help diagnose redirect_uri_mismatch issues.
        // Remove or guard with kDebugMode in production if desired.
        // ignore: avoid_print
        print('[Google OAuth] Expected redirect URI: $expectedRedirect');
      } catch (_) {}
      await supabaseClient.auth.signInWithOAuth(
        OAuthProvider.google,
      );

      // Wait for completion
      return await completer.future.timeout(const Duration(seconds: 60), onTimeout: () {
        authSub.cancel();
        throw Exception('Google OAuth timed out');
      });
    } catch (e) {
      throw Exception('Google OAuth initiation failed: $e');
    }
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
  
  @override
  Future<void> logout() async {
    await supabaseClient.auth.signOut();
  }
}