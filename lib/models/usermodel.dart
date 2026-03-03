import 'package:hive/hive.dart';
part 'usermodel.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String name;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String role;

  UserModel({ required this.name, required this.username, required this.role});

  // factory UserModel.fromJson(Map<String, dynamic> json) {
  //   return UserModel(name: json["name"], role: json["role"]);
  // }
}
