import 'dart:io';

import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/network/supabase_storage.dart';
import 'package:aparna_education/features/profile/data/models/parent_model.dart';
import 'package:aparna_education/features/profile/domain/entities/parent_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ParentRemoteDatasource {
  SupabaseClient get supabaseClient;
  Future<List<Parent>> getParents();
  Future<Parent> getParent(String uid);
  Future<void> addParent({
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
  });
  Future<void> updateParent({
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
    File? profilePic,
    required String occupation,
  });
}

class ParentRemoteDatasourceImpl implements ParentRemoteDatasource {
  @override
  final SupabaseClient supabaseClient;
  
  ParentRemoteDatasourceImpl(this.supabaseClient);

  @override
  Future<void> addParent(
      {required String firstName,
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
      required String occupation}) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw ServerException(message: 'User not authenticated');

      final imageUrl = await SupabaseStorageService.uploadAndGetDownloadUrl('profile-pics', profilePic);
      final parent = ParentModel(
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
        usertype: Usertype.parent,
      );
      await supabaseClient.from('parents').insert(parent.toMap());
      await supabaseClient.from('users').update({
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
        'user_type': 'parent',
      }).eq('uid', user.id);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<Parent> getParent(String uid) async {
    try {
      final response = await supabaseClient
          .from('parents')
          .select()
          .eq('uid', uid)
          .single();
      return ParentModel.fromMap(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Parent>> getParents() async {
    try {
      final response = await supabaseClient.from('parents').select();
      return response.map<Parent>((json) => ParentModel.fromMap(json)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateParent({
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
    File? profilePic,
    required String occupation,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw ServerException(message: 'User not authenticated');

      // Get current parent data
      final currentParentData = await supabaseClient
          .from('parents')
          .select()
          .eq('uid', user.id)
          .single();
      
      final currentParent = ParentModel.fromMap(currentParentData);

      // Upload new profile picture if provided, otherwise keep existing one
      String imageUrl = currentParent.profilePic;
      if (profilePic != null) {
        imageUrl = await SupabaseStorageService.uploadAndGetDownloadUrl('profilePics', profilePic);
      }

      final updatedParent = ParentModel(
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
        usertype: Usertype.parent,
      );

      await supabaseClient.from('parents').update(updatedParent.toMap()).eq('uid', user.id);
      await supabaseClient.from('users').update({
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
        'user_type': toStringValue(Usertype.parent),
      }).eq('uid', user.id);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
