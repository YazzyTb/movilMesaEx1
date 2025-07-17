import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static final UserPreferences _instance = UserPreferences._internal();
  late SharedPreferences _prefs;

  factory UserPreferences() => _instance;

  UserPreferences._internal();

  initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String get token => _prefs.getString('token') ?? '';
  String get email => _prefs.getString('email') ?? '';
  String get name => _prefs.getString('name') ?? '';
  String get image => _prefs.getString('image') ?? '';
  int get clientId => _prefs.getInt("clientId") ?? 0;

  int get selectedPage => _prefs.getInt('selectedPage') ?? 0;

  set token(String token) => _prefs.setString('token', token);
  set email(String email) => _prefs.setString('email', email);
  set name(String name) => _prefs.setString('name', name);
  set image(String image) => _prefs.setString('image', image);
  set clientId(int clientId) => _prefs.setInt('clientId', clientId);

  set selectedPage(int value) => _prefs.setInt("selectedPage", value);

  void setUser(
      {required String? username,
      required String? email,
      required String? name,
      required String? lastName,
      required String? image,
      required int? clientId}) {
    _prefs.setString('email', email ?? '');
    _prefs.setString('name', name ?? '');
    _prefs.setString('image', image ?? '');
    _prefs.setInt('clientID', clientId ?? 0);
  }

  void clearUser() {
    _prefs.setString('token', '');
    _prefs.setString('email', '');
    _prefs.setString('name', '');
    _prefs.setString('image', '');
    _prefs.setInt('clientID', 0);
  }
}
