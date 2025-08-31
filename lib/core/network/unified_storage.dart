import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:aparna_education/core/secrets/secrets.dart';
import 'package:aparna_education/core/network/supabase_storage.dart';
import 'package:aparna_education/core/utils/app_logger.dart';

enum StorageProvider { firebase, supabase }

class UnifiedStorageService {
  static StorageProvider get currentProvider => 
      Secrets.useSupabaseStorage ? StorageProvider.supabase : StorageProvider.firebase;

  /// Main upload method that delegates to the appropriate storage service
  static Future<String> uploadAndGetDownloadUrl(String folderName, File file) async {
    // Validate file before upload
    final String fileName = file.path.split('/').last;
    AppLogger.storageValidation(fileName, 'file type', isValidFileType(file));
    AppLogger.storageValidation(fileName, 'file size', isFileSizeValid(file));
    
    if (!isValidFileType(file)) {
      throw Exception('Invalid file type. Allowed: jpg, jpeg, png, gif, pdf, doc, docx');
    }
    
    if (!isFileSizeValid(file)) {
      throw Exception('File size too large. Maximum allowed: 50MB');
    }
    
    AppLogger.info('🚀 Using storage provider: ${currentProvider.toString().split('.').last}');
    
    try {
      switch (currentProvider) {
        case StorageProvider.firebase:
          return await _uploadToFirebase(folderName, file);
        case StorageProvider.supabase:
          return await _uploadToSupabase(folderName, file);
      }
    } catch (e) {
      AppLogger.error('❌ Unified storage upload failed', e);
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Upload with progress tracking
  static Future<String> uploadWithProgress(
    String folderName, 
    File file,
    Function(double)? onProgress,
  ) async {
    final String fileName = file.path.split('/').last;
    AppLogger.info('📊 Starting upload with progress tracking: $fileName');
    
    try {
      switch (currentProvider) {
        case StorageProvider.firebase:
          return await _uploadToFirebaseWithProgress(folderName, file, onProgress);
        case StorageProvider.supabase:
          return await SupabaseStorageService.uploadWithProgress(folderName, file, onProgress);
      }
    } catch (e) {
      AppLogger.error('❌ Upload with progress failed for $fileName', e);
      throw Exception('Failed to upload file with progress: $e');
    }
  }

  /// Firebase implementation (existing)
  static Future<String> _uploadToFirebase(String folderName, File file) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    String filePath = '$folderName/$fileName';
    
    final double fileSizeInMB = file.lengthSync() / (1024 * 1024);
    AppLogger.storageUpload('Firebase', folderName, fileName, fileSize: '${fileSizeInMB.toStringAsFixed(2)} MB');
    
    try {
      Reference ref = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      AppLogger.storageUploadSuccess('Firebase', folderName, fileName, downloadUrl);
      return downloadUrl;
    } catch (e) {
      AppLogger.storageUploadError('Firebase', folderName, fileName, e);
      rethrow;
    }
  }

  /// Firebase implementation with progress
  static Future<String> _uploadToFirebaseWithProgress(
    String folderName, 
    File file, 
    Function(double)? onProgress,
  ) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    String filePath = '$folderName/$fileName';
    
    try {
      Reference ref = FirebaseStorage.instance.ref().child(filePath);
      UploadTask uploadTask = ref.putFile(file);
      
      // Listen to progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        double progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
        AppLogger.storageProgress('Firebase', fileName, progress);
      });
      
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      
      AppLogger.storageUploadSuccess('Firebase', folderName, fileName, downloadUrl);
      return downloadUrl;
    } catch (e) {
      AppLogger.storageUploadError('Firebase', folderName, fileName, e);
      rethrow;
    }
  }

  /// Supabase implementation
  static Future<String> _uploadToSupabase(String folderName, File file) async {
    return await SupabaseStorageService.uploadAndGetDownloadUrl(folderName, file);
  }

  /// Delete file (works with both providers)
  static Future<void> deleteFile(String folderName, String fileName) async {
    AppLogger.info('🗑️ Deleting file using ${currentProvider.toString().split('.').last}: $fileName');
    
    try {
      switch (currentProvider) {
        case StorageProvider.firebase:
          AppLogger.storageDelete('Firebase', folderName, fileName);
          Reference ref = FirebaseStorage.instance.ref().child('$folderName/$fileName');
          await ref.delete();
          AppLogger.storageDeleteSuccess('Firebase', folderName, fileName);
          break;
        case StorageProvider.supabase:
          await SupabaseStorageService.deleteFile(folderName, fileName);
          break;
      }
    } catch (e) {
      AppLogger.error('❌ Failed to delete file: $fileName', e);
      throw Exception('Failed to delete file: $e');
    }
  }

  /// Get storage provider info
  static String getStorageProviderInfo() {
    final providerName = currentProvider.toString().split('.').last;
    AppLogger.info('📋 Storage provider info requested: $providerName');
    return 'Currently using: $providerName';
  }

  /// Validate file before upload
  static bool isValidFileType(File file) {
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'pdf', 'doc', 'docx'];
    String extension = file.path.split('.').last.toLowerCase();
    final isValid = allowedExtensions.contains(extension);
    
    if (!isValid) {
      AppLogger.warning('⚠️ Invalid file type: $extension. Allowed: ${allowedExtensions.join(', ')}');
    }
    
    return isValid;
  }

  /// Get file size in MB
  static double getFileSizeInMB(File file) {
    int bytes = file.lengthSync();
    double sizeInMB = bytes / (1024 * 1024);
    AppLogger.debug('📏 File size: ${sizeInMB.toStringAsFixed(2)} MB');
    return sizeInMB;
  }

  /// Check if file size is within limits (50MB)
  static bool isFileSizeValid(File file) {
    double sizeInMB = getFileSizeInMB(file);
    final isValid = sizeInMB <= 50;
    
    if (!isValid) {
      AppLogger.warning('⚠️ File size too large: ${sizeInMB.toStringAsFixed(2)} MB (max: 50 MB)');
    }
    
    return isValid;
  }
}
