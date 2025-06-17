class UserView {
  final int id;
  final String? code;
  final String phoneNumber;
  const UserView({required this.id, this.code, required this.phoneNumber});
  //Conversion of user model to map
  Map<String, Object?> toMap() {
    return {'id': id, 'phoneNumber': phoneNumber, 'code': code};
  }

  @override
  String toString() {
    return 'UserView{id: $id, code : $code, name: $phoneNumber}';
  }

  factory UserView.fromMap(Map<String, dynamic> map) {
    return UserView(
      id: map['id'] as int,
      code: map['code'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String,
    );
  }
}
