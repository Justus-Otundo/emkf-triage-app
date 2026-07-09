class AppConstants {
  AppConstants._();

  static const String appName = 'EMKF Triage';
  static const String triageBoxName = 'triage_records';

  static const int maxPriority = 5;
  static const int minPriority = 1;
  static const int criticalPriorityThreshold = 2;

  static const String baseUrl = 'https://api.emkf.org/api/v1';
  static const String triageEndpoint = '/triage';

  static const Duration syncRetryInterval = Duration(seconds: 30);
  static const Duration mockDelay = Duration(seconds: 2);

  /// Probability (0.0–1.0) that the mock remote will simulate a network failure.
  /// Set to 0 for demos; keep >0 to prove the sync queue handles retries.
  static const double mockFailureProbability = 0.3;
}
