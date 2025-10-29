class Contact {
  final String phoneNumber;
  final String countryCode;
  final String lastMessage;
  final DateTime timestamp;

  Contact({
    required this.phoneNumber,
    required this.countryCode,
    required this.lastMessage,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'phoneNumber': phoneNumber,
      'countryCode': countryCode,
      'lastMessage': lastMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      phoneNumber: json['phoneNumber'],
      countryCode: json['countryCode'],
      lastMessage: json['lastMessage'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  String get fullNumber => '$countryCode$phoneNumber';
}
