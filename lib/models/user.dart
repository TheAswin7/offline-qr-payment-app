class User {
  final String id;
  final String phoneNumber;
  final String name;
  final String? merchantId;
  final String? shopName;
  final bool isMerchant;
  final String? language;

  User({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.merchantId,
    this.shopName,
    this.isMerchant = false,
    this.language,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'name': name,
      'merchantId': merchantId,
      'shopName': shopName,
      'isMerchant': isMerchant,
      'language': language,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phoneNumber: json['phoneNumber'] as String,
      name: json['name'] as String,
      merchantId: json['merchantId'] as String?,
      shopName: json['shopName'] as String?,
      isMerchant: json['isMerchant'] as bool? ?? false,
      language: json['language'] as String?,
    );
  }

  User copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? merchantId,
    String? shopName,
    bool? isMerchant,
    String? language,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      merchantId: merchantId ?? this.merchantId,
      shopName: shopName ?? this.shopName,
      isMerchant: isMerchant ?? this.isMerchant,
      language: language ?? this.language,
    );
  }
}

