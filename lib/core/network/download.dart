import 'dart:io';
import 'package:aparna_education/core/network/unified_storage.dart';
import 'package:aparna_education/core/utils/app_logger.dart';

/// Legacy wrapper for backward compatibility
/// This delegates to the UnifiedStorageService which handles both Firebase and Supabase
Future<String> uploadAndGetDownloadUrl(String folderName, File file) async {
  final String fileName = file.path.split('/').last;
  AppLogger.info('🔄 Legacy upload function called for: $fileName');
  
  // Validate file before upload
  if (!UnifiedStorageService.isValidFileType(file)) {
    AppLogger.warning('❌ Legacy upload failed - Invalid file type: $fileName');
    throw Exception('Invalid file type. Allowed: jpg, jpeg, png, gif, pdf, doc, docx');
  }
  
  if (!UnifiedStorageService.isFileSizeValid(file)) {
    AppLogger.warning('❌ Legacy upload failed - File too large: $fileName');
    throw Exception('File size exceeds 50MB limit');
  }
  
  AppLogger.info('➡️ Delegating to UnifiedStorageService: $fileName');
  return await UnifiedStorageService.uploadAndGetDownloadUrl(folderName, file);
}

/// Upload with progress tracking
Future<String> uploadWithProgress(String folderName, File file, Function(double)? onProgress) async {
  final String fileName = file.path.split('/').last;
  AppLogger.info('📊 Legacy upload with progress called for: $fileName');
  
  // Validate file before upload
  if (!UnifiedStorageService.isValidFileType(file)) {
    AppLogger.warning('❌ Legacy upload with progress failed - Invalid file type: $fileName');
    throw Exception('Invalid file type. Allowed: jpg, jpeg, png, gif, pdf, doc, docx');
  }
  
  if (!UnifiedStorageService.isFileSizeValid(file)) {
    AppLogger.warning('❌ Legacy upload with progress failed - File too large: $fileName');
    throw Exception('File size exceeds 50MB limit');
  }
  
  AppLogger.info('➡️ Delegating to UnifiedStorageService with progress: $fileName');
  return await UnifiedStorageService.uploadWithProgress(folderName, file, onProgress);
}
