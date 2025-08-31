import 'dart:io';

import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/network/supabase_storage.dart';
import 'package:aparna_education/features/profile/data/models/language_learner_model.dart';
import 'package:aparna_education/features/profile/domain/entities/language_learner_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class LanguageLearnerRemoteDatasource {
  SupabaseClient get supabaseClient;

  Future<List<LanguageLearner>> getLanguageLearners();
  Future<LanguageLearner> getLanguageLearner(String uid);
  Future<void> addLanguageLearner({
    required String firstName,
    required String middleName,
    required String lastName,
    required String phoneNumber,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
    required String gender,
    required DateTime dob,
    required File profilePic,
    required String occupation,
    required List<String> languagesKnown,
    required List<String> languagesToLearn,
  });
}

class LanguageLearnerRemoteDatasourceImpl
    implements LanguageLearnerRemoteDatasource {
  @override
  final SupabaseClient supabaseClient;

  LanguageLearnerRemoteDatasourceImpl(this.supabaseClient);

  @override
  Future<void> addLanguageLearner({
    required String firstName,
    required String middleName,
    required String lastName,
    required String phoneNumber,
    required String address,
    required String city,
    required String state,
    required String country,
    required String pincode,
    required String gender,
    required DateTime dob,
    required File profilePic,
    required String occupation,
    required List<String> languagesKnown,
    required List<String> languagesToLearn,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw ServerException(message: 'User not authenticated');

      final imageUrl = await SupabaseStorageService.uploadAndGetDownloadUrl('profilePics', profilePic);
      final languageLearner = LanguageLearnerModel(
        uid: user.id,
        email: user.email!,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        address: address,
        city: city,
        state: state,
        country: country,
        pincode: pincode,
        occupation: occupation,
        profilePic: imageUrl,
        gender: gender,
        dob: dob,
        languagesKnown: languagesKnown,
        languagesToLearn: languagesToLearn,
        emailVerified: user.emailConfirmedAt != null,
      );
      
      await supabaseClient.from('language_learners').insert(languageLearner.toMap());
      await supabaseClient.from('users').update({
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
        'user_type': toStringValue(Usertype.languageLearner),
      }).eq('uid', user.id);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<LanguageLearner> getLanguageLearner(String uid) async {
    try {
      final response = await supabaseClient
          .from('language_learners')
          .select()
          .eq('uid', uid)
          .single();
      return LanguageLearnerModel.fromMap(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<LanguageLearner>> getLanguageLearners() async {
    try {
      final response = await supabaseClient.from('language_learners').select();
      return response
          .map<LanguageLearner>((json) => LanguageLearnerModel.fromMap(json))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
