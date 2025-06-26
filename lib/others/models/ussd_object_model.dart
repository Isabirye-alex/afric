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
