import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2, // Number of method calls to be displayed
      errorMethodCount: 8, // Number of method calls if stacktrace is provided
      lineLength: 120, // Width of the output
      colors: true, // Colorful log messages
      printEmojis: true, // Print an emoji for each log message
      printTime: true, // Should each log print contain a timestamp
    ),
  );

  // Debug level logging
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  // Info level logging
  static void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  // Warning level logging
  static void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  // Error level logging
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // Fatal level logging
  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }

  // Storage specific logging methods
  static void storageUpload(String provider, String folderName, String fileName, {String? fileSize}) {
    info('📤 [$provider] Uploading file: $fileName to $folderName${fileSize != null ? ' (Size: $fileSize)' : ''}');
  }

  static void storageUploadSuccess(String provider, String folderName, String fileName, String url) {
    info('✅ [$provider] Upload successful: $fileName → $url');
  }

  static void storageUploadError(String provider, String folderName, String fileName, dynamic error) {
    AppLogger.error('❌ [$provider] Upload failed for $fileName in $folderName', error);
  }

  static void storageDelete(String provider, String folderName, String fileName) {
    info('🗑️ [$provider] Deleting file: $fileName from $folderName');
  }

  static void storageDeleteSuccess(String provider, String folderName, String fileName) {
    info('✅ [$provider] Delete successful: $fileName');
  }

  static void storageDeleteError(String provider, String folderName, String fileName, dynamic error) {
    AppLogger.error('❌ [$provider] Delete failed for $fileName in $folderName', error);
  }

  static void storageBucketInit(String bucketName) {
    info('🗃️ [Supabase] Initializing bucket: $bucketName');
  }

  static void storageBucketInitSuccess(String bucketName) {
    info('✅ [Supabase] Bucket initialized successfully: $bucketName');
  }

  static void storageBucketInitError(String bucketName, dynamic error) {
    AppLogger.error('❌ [Supabase] Bucket initialization failed: $bucketName', error);
  }

  static void storageProgress(String provider, String fileName, double progress) {
    debug('📊 [$provider] Upload progress for $fileName: ${(progress * 100).toStringAsFixed(1)}%');
  }

  static void storageValidation(String fileName, String validationType, bool isValid) {
    if (isValid) {
      debug('✅ File validation passed: $fileName ($validationType)');
    } else {
      warning('⚠️ File validation failed: $fileName ($validationType)');
    }
  }

  // Supabase specific error logging
  static void supabaseRLSError(String bucketName, String fileName) {
    error('🔒 [Supabase] Row Level Security Error for $fileName in bucket: $bucketName');
    warning('💡 [Supabase] SOLUTION: Configure RLS policies in your Supabase dashboard');
    info('📝 [Supabase] Required policies: Allow INSERT/SELECT/UPDATE/DELETE for authenticated users on storage.objects table');
    info('🔗 [Supabase] Dashboard URL: https://supabase.com/dashboard/project/YOUR_PROJECT/storage/policies');
    _printRLSQuickFix();
  }

  static void supabaseBucketNotFound(String bucketName) {
    error('🗃️ [Supabase] Storage bucket not found: $bucketName');
    warning('💡 [Supabase] SOLUTION: Create the bucket in your Supabase dashboard or check bucket name configuration');
    info('🔗 [Supabase] Dashboard URL: https://supabase.com/dashboard/project/YOUR_PROJECT/storage/buckets');
  }

  static void supabaseConnectionError(String operation) {
    error('🌐 [Supabase] Connection error during $operation');
    warning('💡 [Supabase] SOLUTION: Check your internet connection and Supabase project status');
    info('📝 [Supabase] Verify your Supabase URL and API key in secrets.dart');
  }

  static void _printRLSQuickFix() {
    info('');
    info('🚀 QUICK FIX for RLS Error:');
    info('1. Go to your Supabase Dashboard');
    info('2. Navigate to Storage > Policies');
    info('3. Create an INSERT policy with: (auth.role() = \'authenticated\')');
    info('4. Create a SELECT policy with: true');
    info('');
    info('📖 For detailed instructions, see: SUPABASE_RLS_SETUP.md');
    info('');
  }
}
