import 'package:hive/hive.dart';
import '../models/user_model.dart';

class SessionService {
  /// 🔹 Opened Hive box
  static final Box<UserModel> _box = Hive.box<UserModel>("users");

  /// 🔹 Key for storing user
  static const String _userKey = "currentUser";

  // ===========================
  // 🔥 SAVE USER (LOGIN)
  // ===========================
  static Future<void> saveUser(UserModel user) async {
    await _box.put(_userKey, user);
  }

  // ===========================
  // 🔥 GET USER
  // ===========================
  static UserModel? get user {
    return _box.get(_userKey);
  }

  // ===========================
  // 🔥 CHECK LOGIN
  // ===========================
  static bool get isLoggedIn {
    return _box.get(_userKey) != null;
  }

  // ===========================
  // 🔥 GET INDIVIDUAL FIELDS
  // ===========================
  static int? get userId => user?.id;
  static String? get name => user?.name;
  static String? get role => user?.role;
  static String? get username => user?.username;

  // ===========================
  // 🔥 LOGOUT
  // ===========================
  static Future<void> logout() async {
    await _box.clear();
  }
}
