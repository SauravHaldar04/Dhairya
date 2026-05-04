import 'package:aparna_education/core/config/secrets.dart';
import 'package:aparna_education/firebase_options.dart';
import 'package:aparna_education/init_dependencies.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppBootstrap {
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await dotenv.load(fileName: '.env');
      print('✅ Environment variables loaded successfully');
      Secrets.validate();
    } catch (e) {
      print('❌ Failed to load environment variables: $e');
      print('Please ensure .env file exists with all required variables');
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('✅ Firebase initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize Firebase: $e');
    }

    await initDependencies();
  }
}
