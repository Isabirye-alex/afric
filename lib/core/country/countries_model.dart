// class Countries {
//   final String name;
//   final String code;
//
//   Countries({required this.name, required this.code});
//
//   factory Countries.fromJson(Map<String, dynamic> json) {
//     final root = json['idd']?['root'] ?? '';
//     final suffix = (json['idd']?['suffixes'] ?? []).isNotEmpty
//         ? json['idd']['suffixes'][0]
//         : '';
//     return Countries(name: json['name']['common'], code: '$root$suffix');
//   }
// }
