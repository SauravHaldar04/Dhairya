import 'dart:io';

import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/core/network/supabase_storage.dart';
import 'package:aparna_education/features/profile/data/models/teacher_model.dart';
import 'package:aparna_education/features/profile/domain/entities/teacher_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class TeacherRemoteDatasource {
  SupabaseClient get supabaseClient;
  Future<List<Teacher>> getTeachers();
  Future<Teacher> getTeacher(String uid);
  Future<void> addTeacher({
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
    required List<String> board,
    required String workExp,
    required List<String> subjects,
    required File resume,
  });
  
  Future<void> updateTeacher({
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
    required List<String> board,
    required String workExp,
    required List<String> subjects,
    File? resume,
  });
}

class TeacherRemoteDatasorceImpl implements TeacherRemoteDatasource {
  @override
  final SupabaseClient supabaseClient;
  
  TeacherRemoteDatasorceImpl(this.supabaseClient);

  @override
  Future<Teacher> getTeacher(String uid) async {
    try {
      final response = await supabaseClient
          .from('teachers')
          .select()
          .eq('uid', uid)
          .single();
      return TeacherModel.fromMap(response);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<List<Teacher>> getTeachers() async {
    try {
      final response = await supabaseClient.from('teachers').select();
      return response.map<Teacher>((json) => TeacherModel.fromMap(json)).toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> addTeacher(
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
      required List<String> board,
      required String workExp,
      required List<String> subjects,
      required File resume}) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw ServerException(message: 'User not authenticated');

      final imageUrl = await SupabaseStorageService.uploadAndGetDownloadUrl('profile-pictures', profilePic);
      final resumeUrl = await SupabaseStorageService.uploadAndGetDownloadUrl('documents', resume);
      
      final teacher = TeacherModel(
          uid: user.id,
          email: user.email!,
          firstName: firstName,
          middleName: middleName,
          lastName: lastName,
          subjects: subjects,
          profilePic: imageUrl,
          address: address,
          city: city,
          state: state,
          country: country,
          pincode: pincode,
          phoneNumber: phoneNumber,
          gender: gender,
          dob: dob,
          workExp: workExp,
          resume: resumeUrl,
          board: board,
          usertype: Usertype.teacher,
          // Set verification defaults for new teachers
          verified: false,
          verificationStatus: 'pending',
      );
      
      await supabaseClient.from('teachers').insert(teacher.toMap());
      
      await supabaseClient.from('users').update({
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
        'user_type': toStringValue(Usertype.teacher),
      }).eq('uid', user.id);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<void> updateTeacher({
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
    required List<String> board,
    required String workExp,
    required List<String> subjects,
    File? resume,
  }) async {
    try {
      final user = supabaseClient.auth.currentUser;
      if (user == null) throw ServerException(message: 'User not authenticated');

      // Get current teacher data
      final currentTeacherData = await supabaseClient
          .from('teachers')
          .select()
          .eq('uid', user.id)
          .single();
      
      final currentTeacher = TeacherModel.fromMap(currentTeacherData);

      // Upload new profile picture if provided, otherwise keep existing one
      String imageUrl = currentTeacher.profilePic;
      if (profilePic != null) {
        imageUrl = await SupabaseStorageService.uploadAndGetDownloadUrl('profile-pictures', profilePic);
      }

      // Upload new resume if provided, otherwise keep existing one
      String resumeUrl = currentTeacher.resume;
      if (resume != null) {
        resumeUrl = await SupabaseStorageService.uploadAndGetDownloadUrl('documents', resume);
      }

      final updatedTeacher = TeacherModel(
        uid: user.id,
        email: user.email!,
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        subjects: subjects,
        profilePic: imageUrl,
        address: address,
        city: city,
        state: state,
        country: country,
        pincode: pincode,
        phoneNumber: phoneNumber,
        gender: gender,
        dob: dob,
        workExp: workExp,
        resume: resumeUrl,
        board: board,
        usertype: Usertype.teacher,
        // Preserve verification fields from current teacher
        verified: currentTeacher.verified,
        verificationStatus: currentTeacher.verificationStatus,
        verificationDate: currentTeacher.verificationDate,
        verifiedBy: currentTeacher.verifiedBy,
        rejectionReason: currentTeacher.rejectionReason,
      );

      await supabaseClient.from('teachers').update(updatedTeacher.toMap()).eq('uid', user.id);
      await supabaseClient.from('users').update({
        'first_name': firstName,
        'last_name': lastName,
        'middle_name': middleName,
        'user_type': toStringValue(Usertype.teacher),
      }).eq('uid', user.id);
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
