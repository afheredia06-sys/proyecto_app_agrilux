// lib/config/app_config.dart — Equivalente a .env.example
class AppConfig {
  static const String openAiApiKey      = String.fromEnvironment('OPENAI_API_KEY',               defaultValue: '');
  static const String firebaseApiKey    = String.fromEnvironment('FIREBASE_API_KEY',              defaultValue: '');
  static const String firebaseAuthDomain= String.fromEnvironment('FIREBASE_AUTH_DOMAIN',          defaultValue: '');
  static const String firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID',           defaultValue: '');
  static const String firebaseStorageBucket= String.fromEnvironment('FIREBASE_STORAGE_BUCKET',    defaultValue: '');
  static const String firebaseMsgSenderId= String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: '');
  static const String firebaseAppId     = String.fromEnvironment('FIREBASE_APP_ID',               defaultValue: '');
}
