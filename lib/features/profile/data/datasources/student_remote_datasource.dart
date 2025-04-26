import 'package:aparna_education/core/enums/usertype_enum.dart';
import 'package:aparna_education/core/error/server_exception.dart';
import 'package:aparna_education/features/profile/data/models/parent_model.dart';
import 'package:aparna_education/features/profile/data/models/student_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract interface class StudentRemoteDatasource {
  FirebaseFirestore get firestore;
  FirebaseAuth get firebaseAuth;
  
  Future<void> addStudent({
    required String firstName,
    required String middleName,
    required String lastName,
    required String standard,
    required List<String> subjects,
    required String board,
    required String medium,
  });
  
  Future<List<StudentModel>> getStudentsByParent(String parentId);
}

class StudentRemoteDatasourceImpl implements StudentRemoteDatasource {
  @override
  final FirebaseFirestore firestore;
  @override
  final FirebaseAuth firebaseAuth;
  
  StudentRemoteDatasourceImpl(this.firestore, this.firebaseAuth);
  
  @override
  Future<void> addStudent({
    required String firstName,
    required String middleName,
    required String lastName,
    required String standard,
    required List<String> subjects,
    required String board,
    required String medium,
  }) async {
    try {
      final parentId = firebaseAuth.currentUser!.uid;
      // Get parent data to associate with student
      final parentDoc = await firestore.collection('parents').doc(parentId).get();
      
      if (!parentDoc.exists) {
        throw ServerException(message: 'Parent not found');
      }
      
      final parent = ParentModel.fromMap(parentDoc.data()!);
      
      // Create a unique ID for the student
      final studentUid = '${parentId}_student_${DateTime.now().millisecondsSinceEpoch}';
      
      // Create student model
      final student = StudentModel(
        parent: parentId,
        standard: standard,
        subjects: subjects,
        board: board,
        medium: medium,
        uid: studentUid,
        email: '', // Student may not have email yet
        firstName: firstName,
        middleName: middleName,
        lastName: lastName,
        emailVerified: false,
      
      );
      
      // Save to students collection
      await firestore.collection('students').doc(studentUid).set(student.toMap());
      
      // Update parent document - add student reference to parent's students array
      // First get the current students array
      final parentStudentsRef = firestore.collection('parents').doc(parentId);
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(parentStudentsRef);
        List<dynamic> students = snapshot.data()!['students'] ?? [];
        students.add(studentUid);
        transaction.update(parentStudentsRef, {'students': students});
      });
      
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
  
  @override
  Future<List<StudentModel>> getStudentsByParent(String parentId) async {
    try {
      final studentsQuery = await firestore
          .collection('students')
          .where('parent.uid', isEqualTo: parentId)
          .get();
          
      return studentsQuery.docs
          .map((doc) => StudentModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(message: e.toString());
    }
  }
}
