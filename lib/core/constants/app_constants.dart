class AppConstants {
  AppConstants._();

  static const String appName = 'EMKF Triage';
  static const String triageBoxName = 'triage_records';
  static const String syncBoxName = 'sync_queue';

  static const int maxPriority = 5;
  static const int minPriority = 1;
  static const int criticalPriorityThreshold = 2;

  static const String baseUrl = 'https://api.emkf.org/api/v1';
  static const String triageEndpoint = '/triage';

  static const Duration syncRetryInterval = Duration(seconds: 30);
  static const Duration mockDelay = Duration(seconds: 2);
}
