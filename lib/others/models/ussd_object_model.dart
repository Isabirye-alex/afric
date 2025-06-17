class UssdViewObject {
  final String phoneNumber;
  final String text;
  final String value;
  final List? options;

  UssdViewObject({
    required this.phoneNumber,
    required this.text,
    required this.value,
    this.options,
  });
  Map<String, dynamic> toJson() {
    return {'phoneNumber': phoneNumber, 'text': text, 'value': value};
  }

  factory UssdViewObject.fromJson(Map<String, dynamic> json) {
    return UssdViewObject(
      phoneNumber: json['phoneNumber'] as String,
      text: json['text'] as String,
      value: json['value'] as String,
      options: json['options'] != null
          ? List<String>.from(json['options'])
          : null,
    );
  }
  factory UssdViewObject.fromUssdString(
    String text, {
    String phoneNumber = '',
    String value = '',
  }) {
    final lines = text.split('\n');
    final options = lines.isNotEmpty
        ? lines.sublist(0).where((line) => line.isNotEmpty).toList()
        : [];
    return UssdViewObject(
      phoneNumber: phoneNumber,
      text: text,
      value: value,
      options: options,
    );
  }
}
