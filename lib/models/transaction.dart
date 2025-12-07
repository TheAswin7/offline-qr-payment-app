enum TransactionStatus {
  offlineConfirmed,
  pendingSync,
  synced,
  failed,
}

enum TransactionType {
  sent,
  received,
}

class Transaction {
  final String id;
  final String amount;
  final String counterpartyId;
  final String counterpartyName;
  final DateTime timestamp;
  final TransactionStatus status;
  final TransactionType type;
  final String? merchantId;
  final String? notes;

  Transaction({
    required this.id,
    required this.amount,
    required this.counterpartyId,
    required this.counterpartyName,
    required this.timestamp,
    required this.status,
    required this.type,
    this.merchantId,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'counterpartyId': counterpartyId,
      'counterpartyName': counterpartyName,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'type': type.name,
      'merchantId': merchantId,
      'notes': notes,
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: json['amount'] as String,
      counterpartyId: json['counterpartyId'] as String,
      counterpartyName: json['counterpartyName'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pendingSync,
      ),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.sent,
      ),
      merchantId: json['merchantId'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Transaction copyWith({
    String? id,
    String? amount,
    String? counterpartyId,
    String? counterpartyName,
    DateTime? timestamp,
    TransactionStatus? status,
    TransactionType? type,
    String? merchantId,
    String? notes,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      counterpartyId: counterpartyId ?? this.counterpartyId,
      counterpartyName: counterpartyName ?? this.counterpartyName,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      type: type ?? this.type,
      merchantId: merchantId ?? this.merchantId,
      notes: notes ?? this.notes,
    );
  }
}





