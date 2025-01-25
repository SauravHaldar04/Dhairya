import 'dart:io';
import 'package:aparna_education/secrets/secrets.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_storage/firebase_storage.dart';

// Future<String> uploadAndGetDownloadUrl(String folderName, File file) async {
//   String filePath = '$folderName';
//   Reference ref = FirebaseStorage.instance.ref().child(filePath);
//   UploadTask uploadTask = ref.putFile(file);
//   TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
//   String downloadUrl = await taskSnapshot.ref.getDownloadURL();
//   return downloadUrl;
// }

Future<String> uploadAndGetDownloadUrl(String folderName, File file) async {
  final cloudinary = Cloudinary.unsignedConfig(
    cloudName: Secrets.cloudName,
  );
  final response = await cloudinary.unsignedUpload(
      uploadPreset: Secrets.uploadPreset,
      file: file.path,
      fileBytes: file.readAsBytesSync(),
      folder: folderName,
      fileName: file.path.split('/').last,
      resourceType: CloudinaryResourceType.image,
      progressCallback: (count, total) {
        print('Uploading image from file with progress: $count/$total');
      });

  if (response.isSuccessful) {
   return response.secureUrl!;
  }
  throw Exception('Failed to upload image');
}
