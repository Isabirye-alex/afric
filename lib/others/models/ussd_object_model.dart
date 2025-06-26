// This file defines a model for USSD (Unstructured Supplementary Service Data) view objects.
// It includes a class that represents the USSD view object with properties for phone number, text
class UssdViewObject {
  final String phoneNumber;
  final String text;
  final String value;
  final List? options;
// This class represents a USSD view object with properties for phone number, text, value, and options
  /// Constructor for UssdViewObject
  UssdViewObject({
    required this.phoneNumber,
    required this.text,
    required this.value,
    this.options,
  });
// Factory constructor to create a UssdViewObject from a USSD string
  /// This method takes a USSD string and extracts the phone number, text, value,
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
