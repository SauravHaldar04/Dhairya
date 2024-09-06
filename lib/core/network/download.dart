import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadAndGetDownloadUrl(String folderName, File file) async {
  String filePath = '$folderName';
  Reference ref = FirebaseStorage.instance.ref().child(filePath);
  UploadTask uploadTask = ref.putFile(file);
  TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
  String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  return downloadUrl;
}
