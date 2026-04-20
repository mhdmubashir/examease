class AppConfigModel {
  final bool maintenanceMode;
  final String maintenanceMessage;
  final String minAppVersion;
  final String latestAppVersion;
  final bool forceUpdate;
  final String supportEmail;
  final String privacyPolicyUrl;
  final String termsConditionsUrl;
  final String primaryColor;

  AppConfigModel({
    required this.maintenanceMode,
    required this.maintenanceMessage,
    required this.minAppVersion,
    required this.latestAppVersion,
    required this.forceUpdate,
    required this.supportEmail,
    required this.privacyPolicyUrl,
    required this.termsConditionsUrl,
    required this.primaryColor,
  });

  factory AppConfigModel.fromJson(Map<String, dynamic> json) {
    return AppConfigModel(
      maintenanceMode: json['maintenanceMode'] as bool? ?? false,
      maintenanceMessage:
          json['maintenanceMessage'] as String? ?? 'Under maintenance',
      minAppVersion: json['minAppVersion'] as String? ?? '1.0.0',
      latestAppVersion: json['latestAppVersion'] as String? ?? '1.0.0',
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      supportEmail: json['supportEmail'] as String? ?? '',
      privacyPolicyUrl: json['privacyPolicyUrl'] as String? ?? '',
      termsConditionsUrl: json['termsConditionsUrl'] as String? ?? '',
      primaryColor: json['primaryColor'] as String? ?? '#1E88E5',
    );
  }
}
