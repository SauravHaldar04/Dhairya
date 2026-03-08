// auth_remote_datasources.dart

import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/secrets/secrets.dart';
import 'package:aparna_education/features/auth/data/models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user == null) {
        throw ServerException(message: 'Login failed. Please check your credentials.');
      }
      
      final userData = await supabaseClient
          .from('users')
          .select()
          .eq('uid', response.user!.id)
          .single();
      
      // Debug logging
      print('🔍 DEBUG loginWithEmailAndPassword: user_type from DB = ${userData['user_type']}');
      final parsedType = getEnumFromString(userData['user_type']);
      print('🔍 DEBUG loginWithEmailAndPassword: parsed userType = $parsedType');
      
      // Check if Supabase auth user has confirmed email
      final authEmailVerified = response.user!.emailConfirmedAt != null;
      final dbEmailVerified = userData['email_verified'] as bool? ?? false;
      
      // Sync: If Supabase says verified but DB says not, update DB
      if (authEmailVerified && !dbEmailVerified) {
        await supabaseClient.from('users').update({
          'email_verified': true,
        }).eq('uid', response.user!.id);
        print('✅ Synced email_verified status in database');
      }
      
      return UserModel(
        uid: response.user!.id,
        email: userData['email'],
        firstName: userData['first_name'],
        middleName: userData['middle_name'],
        lastName: userData['last_name'],
        emailVerified: authEmailVerified, // Use Supabase auth as source of truth
        userType: parsedType,
      );
    } on AuthException catch (e) {
      // Handle Supabase authentication errors
      String errorMessage = 'Login failed';
      if (e.message.toLowerCase().contains('invalid')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (e.message.toLowerCase().contains('not found')) {
        errorMessage = 'No account found with this email. Please sign up first.';
      } else if (e.message.toLowerCase().contains('email not confirmed')) {
        errorMessage = 'Please verify your email before logging in.';
      } else {
        errorMessage = e.message;
      }
      throw ServerException(message: errorMessage);
    } on PostgrestException catch (e) {
      // Handle database errors
      throw ServerException(message: 'Failed to retrieve user data: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'An unexpected error occurred: ${e.toString()}');
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
      // Initialize GoogleSignIn instance with client IDs
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;
      
      // Initialize with proper configuration
      await googleSignIn.initialize(
        clientId: Secrets.googleIosClientId,
        serverClientId: Secrets.googleWebClientId,
      );

      // Perform the authentication
      final googleAccount = await googleSignIn.authenticate();

      // Get authorization and authentication details
      final googleAuthorization = await googleAccount.authorizationClient.authorizationForScopes([
        'email',
        'profile',
        'openid',
      ]);
      final googleAuthentication = googleAccount.authentication;
      final idToken = googleAuthentication.idToken;
      final accessToken = googleAuthorization?.accessToken;

      if (idToken == null) {
        throw ServerException(message: 'No ID Token found from Google sign-in');
      }

      // Sign in to Supabase with the Google tokens
      final response = await supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = response.user;
      if (user == null) {
        throw ServerException(message: 'Failed to authenticate with Supabase');
      }

      // Check if user exists in database
      final existing = await supabaseClient
          .from('users')
          .select()
          .eq('uid', user.id)
          .maybeSingle();

      if (existing == null) {
        // Create new user record
        final displayName = user.userMetadata?['full_name'] as String? ?? '';
        final parts = displayName.split(' ');
        final firstName = parts.isNotEmpty ? parts.first : '';
        final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

        await supabaseClient.from('users').insert({
          'uid': user.id,
          'email': user.email ?? '',
          'first_name': firstName,
          'middle_name': '',
          'last_name': lastName,
          'email_verified': true, // Google accounts are verified
          'user_type': toStringValue(Usertype.none),
        });

        return UserModel(
          uid: user.id,
          email: user.email ?? '',
          firstName: firstName,
          middleName: '',
          lastName: lastName,
          emailVerified: true,
          userType: Usertype.none,
        );
      } else {
        // Return existing user
        // For Google sign-in, ensure email_verified is true
        final emailVerified = existing['email_verified'] as bool? ?? true;
        
        // Update database if not already verified (Google accounts are always verified)
        if (!emailVerified) {
          await supabaseClient.from('users').update({
            'email_verified': true,
          }).eq('uid', user.id);
        }
        
        return UserModel(
          uid: user.id,
          email: existing['email'],
          firstName: existing['first_name'],
          middleName: existing['middle_name'],
          lastName: existing['last_name'],
          emailVerified: true, // Google accounts are always verified
          userType: getEnumFromString(existing['user_type']),
        );
      }
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'Google sign-in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) return null;
    final userData = await supabaseClient.from('users').select().eq('uid', user.id).single();
    
    // Debug logging
    print('🔍 DEBUG getCurrentUser: user_type from DB = ${userData['user_type']}');
    final parsedType = getEnumFromString(userData['user_type']);
    print('🔍 DEBUG getCurrentUser: parsed userType = $parsedType');
    
    // Check Supabase auth verification status (source of truth)
    final authEmailVerified = user.emailConfirmedAt != null;
    final dbEmailVerified = userData['email_verified'] as bool? ?? false;
    
    // Sync: If Supabase says verified but DB says not, update DB
    if (authEmailVerified && !dbEmailVerified) {
      await supabaseClient.from('users').update({
        'email_verified': true,
      }).eq('uid', user.id);
      print('✅ Synced email_verified status in database (getCurrentUser)');
    }
    
    return UserModel(
      uid: user.id,
      email: userData['email'],
      firstName: userData['first_name'],
      middleName: userData['middle_name'],
      lastName: userData['last_name'],
      emailVerified: authEmailVerified, // Use Supabase auth as source of truth
      userType: parsedType,
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