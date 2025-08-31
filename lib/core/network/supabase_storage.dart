import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:aparna_education/core/secrets/secrets.dart';
import 'package:aparna_education/core/utils/app_logger.dart';

class SupabaseStorageService {
  static final _supabase = Supabase.instance.client;

  /// Upload file to Supabase Storage and get public URL
  static Future<String> uploadAndGetDownloadUrl(String folderName, File file) async {
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    final String filePath = '$folderName/$fileName';
    final String bucket = _getBucketName(folderName);
    
    // Log upload start with file size
    final double fileSizeInMB = file.lengthSync() / (1024 * 1024);
    AppLogger.storageUpload('Supabase', folderName, fileName, fileSize: '${fileSizeInMB.toStringAsFixed(2)} MB');
    
    try {
      // Upload file to Supabase Storage
      AppLogger.debug('[Supabase] Uploading to bucket: $bucket, path: $filePath');
      
      await _supabase.storage
          .from(bucket)
          .upload(filePath, file);

      // Get public URL
      String publicUrl = _supabase.storage
          .from(bucket)
          .getPublicUrl(filePath);

      AppLogger.storageUploadSuccess('Supabase', folderName, fileName, publicUrl);
      return publicUrl;
    } catch (e) {
      AppLogger.storageUploadError('Supabase', folderName, fileName, e);
      
      // Provide specific guidance for common errors
      if (e.toString().contains('row-level security') || e.toString().contains('Unauthorized')) {
        AppLogger.supabaseRLSError(bucket, fileName);
        throw Exception('Supabase Storage Access Denied: Row Level Security policies need to be configured. Please check your Supabase dashboard under Storage > Policies.');
      } else if (e.toString().contains('Bucket not found')) {
        AppLogger.supabaseBucketNotFound(bucket);
        throw Exception('Storage bucket not found: $bucket. Please ensure bucket exists in Supabase.');
      } else if (e.toString().contains('File size')) {
        AppLogger.error('[Supabase] 📏 Size Error: File too large (${fileSizeInMB.toStringAsFixed(2)} MB)');
        throw Exception('File size exceeds limit. Maximum allowed: 50MB');
      }
      
      throw Exception('Failed to upload file to Supabase: $e');
    }
  }

  /// Upload with progress tracking (basic implementation)
  static Future<String> uploadWithProgress(
    String folderName, 
    File file,
    Function(double)? onProgress,
  ) async {
    final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
    AppLogger.storageProgress('Supabase', fileName, 0.0);
    
    try {
      // Note: Supabase doesn't have built-in progress tracking like Firebase
      // For now, we'll call the progress callback at start and end
      onProgress?.call(0.0);
      
      String result = await uploadAndGetDownloadUrl(folderName, file);
      
      onProgress?.call(1.0);
      AppLogger.storageProgress('Supabase', fileName, 1.0);
      return result;
    } catch (e) {
      AppLogger.storageUploadError('Supabase', folderName, fileName, e);
      throw Exception('Failed to upload file with progress: $e');
    }
  }

  /// Delete file from storage
  static Future<void> deleteFile(String folderName, String fileName) async {
    AppLogger.storageDelete('Supabase', folderName, fileName);
    
    try {
      String bucket = _getBucketName(folderName);
      String filePath = '$folderName/$fileName';
      
      AppLogger.debug('[Supabase] Deleting from bucket: $bucket, path: $filePath');
      
      await _supabase.storage
          .from(bucket)
          .remove([filePath]);
          
      AppLogger.storageDeleteSuccess('Supabase', folderName, fileName);
    } catch (e) {
      AppLogger.storageDeleteError('Supabase', folderName, fileName, e);
      throw Exception('Failed to delete file: $e');
    }
  }

  /// List files in a folder
  static Future<List<FileObject>> listFiles(String folderName) async {
    AppLogger.debug('[Supabase] Listing files in folder: $folderName');
    
    try {
      String bucket = _getBucketName(folderName);
      
      final files = await _supabase.storage
          .from(bucket)
          .list(path: folderName);
          
      AppLogger.info('[Supabase] Found ${files.length} files in $folderName');
      return files;
    } catch (e) {
      AppLogger.error('[Supabase] Failed to list files in $folderName', e);
      throw Exception('Failed to list files: $e');
    }
  }

  /// Check if file exists
  static Future<bool> fileExists(String folderName, String fileName) async {
    AppLogger.debug('[Supabase] Checking if file exists: $fileName in $folderName');
    
    try {
      String bucket = _getBucketName(folderName);
      String filePath = '$folderName/$fileName';
      
      await _supabase.storage
          .from(bucket)
          .download(filePath);
          
      AppLogger.debug('[Supabase] File exists: $fileName');
      return true;
    } catch (e) {
      AppLogger.debug('[Supabase] File does not exist: $fileName');
      return false;
    }
  }

  /// Get appropriate bucket name based on folder type
  static String _getBucketName(String folderName) {
    switch (folderName.toLowerCase()) {
      case 'profile-pictures':
      case 'profilepictures':
        return Secrets.profilePicturesBucket;
      case 'documents':
      case 'resumes':
      case 'pdfs':
        return Secrets.documentsBucket;
      default:
        return Secrets.userFilesBucket;
    }
  }

  /// Initialize storage buckets (call this during app setup)
  static Future<void> initializeStorageBuckets() async {
    AppLogger.info('[Supabase] Starting storage buckets initialization');
    
    try {
      final buckets = [
        Secrets.userFilesBucket,
        Secrets.profilePicturesBucket,
        Secrets.documentsBucket,
      ];

      for (String bucketName in buckets) {
        AppLogger.storageBucketInit(bucketName);
        try {
          // Try to get bucket info, if it doesn't exist, it will throw an error
          await _supabase.storage.getBucket(bucketName);
          AppLogger.info('[Supabase] Bucket already exists: $bucketName');
        } catch (e) {
          // Bucket doesn't exist, create it
          AppLogger.info('[Supabase] Creating new bucket: $bucketName');
          await _supabase.storage.createBucket(
            bucketName,
            BucketOptions(
              public: true, // Make buckets public for easy access
              fileSizeLimit: '50MB', // 50MB limit
              allowedMimeTypes: [
                'image/jpeg',
                'image/png', 
                'image/gif',
                'application/pdf',
                'application/msword',
                'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
              ],
            ),
          );
          AppLogger.storageBucketInitSuccess(bucketName);
        }
      }
      
      AppLogger.info('[Supabase] All storage buckets initialized successfully');
      AppLogger.warning('[Supabase] 🔒 IMPORTANT: Make sure to configure Row Level Security policies in your Supabase dashboard');
      AppLogger.info('[Supabase] 📝 RLS Policy needed: Allow INSERT/SELECT for authenticated users on storage.objects');
    } catch (e) {
      AppLogger.storageBucketInitError('initialization', e);
      AppLogger.error('[Supabase] 🚨 Bucket initialization failed. Check your Supabase credentials and network connection', e);
      // Don't throw here as buckets might already exist
    }
  }
}
