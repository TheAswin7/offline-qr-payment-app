class Wallet {
  final String userId;
  final String offlineBalance;
  final String onlineBalance;
  final String offlineLimit;
  final DateTime lastUpdated;

  Wallet({
    required this.userId,
    required this.offlineBalance,
    required this.onlineBalance,
    required this.offlineLimit,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'offlineBalance': offlineBalance,
      'onlineBalance': onlineBalance,
      'offlineLimit': offlineLimit,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      userId: json['userId'] as String,
      offlineBalance: json['offlineBalance'] as String,
      onlineBalance: json['onlineBalance'] as String,
      offlineLimit: json['offlineLimit'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Wallet copyWith({
    String? userId,
    String? offlineBalance,
    String? onlineBalance,
    String? offlineLimit,
    DateTime? lastUpdated,
  }) {
    return Wallet(
      userId: userId ?? this.userId,
      offlineBalance: offlineBalance ?? this.offlineBalance,
      onlineBalance: onlineBalance ?? this.onlineBalance,
      offlineLimit: offlineLimit ?? this.offlineLimit,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}





